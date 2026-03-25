# Shell functions

# Create a new directory and enter it
mkd() { mkdir -p "$@" && cd "$_"; }

# Change to top-most Finder window location
cdf() { cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"; }

# Determine size of a file or total size of a directory
fs() {
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh
    else
        local arg=-sh
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@"
    else
        du $arg .[^.]* ./*
    fi
}

# Create a .tar.gz archive
targz() {
    local tmpFile="${@%/}.tar"
    tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1
    local size=$(stat -f"%z" "${tmpFile}" 2>/dev/null || stat -c"%s" "${tmpFile}" 2>/dev/null)
    local cmd=""
    if (( size < 52428800 )) && hash zopfli 2>/dev/null; then
        cmd="zopfli"
    elif hash pigz 2>/dev/null; then
        cmd="pigz"
    else
        cmd="gzip"
    fi
    echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`..."
    "${cmd}" -v "${tmpFile}" || return 1
    [ -f "${tmpFile}" ] && rm "${tmpFile}"
    echo "Done."
}

# Compare original and gzipped file size
gz() {
    local origsize=$(wc -c < "$1")
    local gzipsize=$(gzip -c "$1" | wc -c)
    local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
    printf "orig: %d bytes\n" "$origsize"
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Run `dig` and display the most useful info
digga() { dig +nocmd "$1" any +multiline +noall +answer; }

# Start an HTTP server from current directory
server() {
    local port="${1:-8000}"
    sleep 1 && open "http://localhost:${port}/" &
    python3 -m http.server "$port"
}

# Show SSL certificate names for a domain
getcertnames() {
    if [ -z "${1}" ]; then
        echo "ERROR: No domain specified."
        return 1
    fi
    local domain="${1}"
    echo "Testing ${domain}..."
    local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
        | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1)
    if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText=$(echo "${tmp}" \
            | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
            no_serial, no_sigdump, no_signame, no_validity, no_version")
        echo "Common Name:"
        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//"
        echo ""
        echo "Subject Alternative Name(s):"
        echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
            | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
    else
        echo "ERROR: Certificate not found."
        return 1
    fi
}

# `o` opens the current directory or given location
o() {
    if [ $# -eq 0 ]; then
        open .
    else
        open "$@"
    fi
}

# `tre` - tree with hidden files, color, ignoring .git
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Create a data URL from a file
dataurl() {
    local mimeType=$(file -b --mime-type "$1")
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8"
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}
