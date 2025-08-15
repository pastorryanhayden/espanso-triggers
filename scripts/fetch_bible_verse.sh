#!/bin/bash

# Parse the input argument (e.g., "luke11:26-36" or "gen1:1")
INPUT="$1"

# Convert common book abbreviations to full names for the API
convert_book_name() {
    local book="$1"
    book=$(echo "$book" | tr '[:upper:]' '[:lower:]')

    case "$book" in
        gen) echo "genesis";;
        exo|ex) echo "exodus";;
        lev) echo "leviticus";;
        num) echo "numbers";;
        deu|deut) echo "deuteronomy";;
        jos|josh) echo "joshua";;
        jdg|judg) echo "judges";;
        rut|ruth) echo "ruth";;
        1sa|1sam) echo "1samuel";;
        2sa|2sam) echo "2samuel";;
        1ki|1king) echo "1kings";;
        2ki|2king) echo "2kings";;
        1ch|1chr|1chron) echo "1chronicles";;
        2ch|2chr|2chron) echo "2chronicles";;
        ezr) echo "ezra";;
        neh) echo "nehemiah";;
        est|esth) echo "esther";;
        job) echo "job";;
        psa|ps|psalm) echo "psalms";;
        pro|prov) echo "proverbs";;
        ecc|eccl) echo "ecclesiastes";;
        son|song|sos) echo "song%20of%20solomon";;
        isa) echo "isaiah";;
        jer) echo "jeremiah";;
        lam) echo "lamentations";;
        eze|ezek) echo "ezekiel";;
        dan) echo "daniel";;
        hos) echo "hosea";;
        joe) echo "joel";;
        amo) echo "amos";;
        oba|obad) echo "obadiah";;
        jon) echo "jonah";;
        mic) echo "micah";;
        nah) echo "nahum";;
        hab) echo "habakkuk";;
        zep|zeph) echo "zephaniah";;
        hag) echo "haggai";;
        zec|zech) echo "zechariah";;
        mal) echo "malachi";;
        mat|matt) echo "matthew";;
        mar|mark) echo "mark";;
        luk|luke) echo "luke";;
        joh|john) echo "john";;
        act) echo "acts";;
        rom) echo "romans";;
        1co|1cor) echo "1corinthians";;
        2co|2cor) echo "2corinthians";;
        gal) echo "galatians";;
        eph) echo "ephesians";;
        phi|phil|php) echo "philippians";;
        col) echo "colossians";;
        1th|1thes|1thess) echo "1thessalonians";;
        2th|2thes|2thess) echo "2thessalonians";;
        1ti|1tim) echo "1timothy";;
        2ti|2tim) echo "2timothy";;
        tit) echo "titus";;
        phm|philem) echo "philemon";;
        heb) echo "hebrews";;
        jam|jas) echo "james";;
        1pe|1pet) echo "1peter";;
        2pe|2pet) echo "2peter";;
        1jo|1jn|1john) echo "1john";;
        2jo|2jn|2john) echo "2john";;
        3jo|3jn|3john) echo "3john";;
        jud|jude) echo "jude";;
        rev) echo "revelation";;
        *) echo "$book";;  # Return as-is if not an abbreviation
    esac
}

# Extract book and reference from input
# Handle inputs like "luke11:26-36" or "1cor13:1-13"
if [[ "$INPUT" =~ ^([0-9]?[a-zA-Z]+)([0-9]+:[0-9]+(-[0-9]+)?)$ ]]; then
    BOOK="${BASH_REMATCH[1]}"
    REFERENCE="${BASH_REMATCH[2]}"
else
    echo "Invalid format. Use format like 'luke11:26-36' or 'gen1:1'"
    exit 1
fi

# Convert book abbreviation to full name
BOOK_FULL=$(convert_book_name "$BOOK")

# Construct the API URL
API_URL="https://bible-api.com/${BOOK_FULL}${REFERENCE}?translation=kjv"

# Fetch the verse(s) from the API
RESPONSE=$(curl -s "$API_URL")

# Check if the response contains an error
if echo "$RESPONSE" | grep -q '"error"'; then
    echo "Error fetching verse. Please check the reference."
    exit 1
fi

# Extract and format the text
# Using jq if available, otherwise using sed/grep
if command -v jq &> /dev/null; then
    TEXT=$(echo "$RESPONSE" | jq -r '.text')
    REFERENCE_FULL=$(echo "$RESPONSE" | jq -r '.reference')
    # Replace newlines with spaces to keep verse on one line
    TEXT=$(echo "$TEXT" | tr '\n' ' ' | sed 's/  */ /g')
    echo "> ${TEXT}"
    echo "> — ${REFERENCE_FULL} (KJV)"
else
    # Fallback method without jq
    TEXT=$(echo "$RESPONSE" | sed -n 's/.*"text":"\([^"]*\)".*/\1/p' | sed 's/\\n/ /g')
    REFERENCE_FULL=$(echo "$RESPONSE" | sed -n 's/.*"reference":"\([^"]*\)".*/\1/p')
    echo "> ${TEXT}"
    echo "> — ${REFERENCE_FULL} (KJV)"
fi
