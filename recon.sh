#!/bin/bash

# Check for domain input
if [ -z "$1" ]; then
    echo "Usage: ./recon.sh example.com"
    exit 1
fi

DOMAIN=$1
OUTPUT_DIR="result_$DOMAIN"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "[+] 1. Running subfinder to collect subdomains..."
subfinder -d "$DOMAIN" -silent | sort -u > "$OUTPUT_DIR/subs.txt"

echo "[+] 2. Checking active hosts via httpx with rate limiting..."
httpx -l "$OUTPUT_DIR/subs.txt" -silent -mc 200,301,302,403 -rl 100 > "$OUTPUT_DIR/active.txt"

echo "[+] 3. Fetching URLs via gau and filtering static extensions..."
cat "$OUTPUT_DIR/active.txt" | gau --threads 5 | grep -vE "\.(jpg|jpeg|png|gif|css|svg|woff|woff2|ttf|eot|ico)$" | sort -u > "$OUTPUT_DIR/urls.txt"

echo "[+] 4. Running targeted nuclei scan (Medium, High, Critical severities)..."
nuclei -l "$OUTPUT_DIR/urls.txt" \
       -severity medium,high,critical \
       -rl 30 -c 10 \
       -o "$OUTPUT_DIR/vulnerabilities.txt"

echo "[+] Recon completed successfully! Results saved in: $OUTPUT_DIR"
