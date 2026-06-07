f(){
    if [[ "$1" == "--help" || "$1" == "-h" ]] || [[ -z "$1" ]]; then
        echo "Usage: $0 <DOMAIN> <WORDLIST>"
        echo "Output: subs-DOMAIN.txt, subs-probe-DOMAIN.txt, subs-ip-DOMAIN.txt"
        return 0
    fi
 
    DOMAIN=$1
    WORDLIST=$2
    

    subfinder -d "$DOMAIN" -all -silent -o tmp-subs-$DOMAIN.txt && \
    (cat tmp-subs-$DOMAIN.txt; dnsx -d "$DOMAIN" -w "$WORDLIST" -silent -a -resp-only) | \
    sort -u > subs-$DOMAIN.txt && \
    rm tmp-subs-$DOMAIN.txt && \
    httpx-pd -l subs-$DOMAIN.txt -silent -sc -o subs-probe-$DOMAIN.txt && \
    httpx-pd -l subs-$DOMAIN.txt -silent -ip | awk '{for(i=1;i<=NF;i++)if($i~/^\[[0-9a-fA-F:.]+\]$/){gsub(/[\[\]]/,"",$i);print $i}}' | sort -u > subs-ip-$DOMAIN.txt && \
    clear && \
    echo "subdomains: $(wc -l < subs-$DOMAIN.txt 2>/dev/null || echo 0)" && \
    echo "probes: $(wc -l < subs-probe-$DOMAIN.txt 2>/dev/null || echo 0)" && \
    echo "ips: $(wc -l < subs-ip-$DOMAIN.txt 2>/dev/null || echo 0)"
}
f "$1" "$2"