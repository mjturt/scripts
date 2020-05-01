#!/usr/bin/env bash
# Even losing weight can be made fun if you write script for that
# Author: mjturt <maks.turtiainen@gmail.com> (https://github.com/mjturt)
# Usage: ./weight.sh --help

DATA_DIR="$HOME/cloud/scripts/misc/weight/data"
CSV_FILE="${DATA_DIR}/weight.csv"
CSV_FILE_BACKUP="${DATA_DIR}/.weight-backup.csv"
OUTPUTIMAGE="${DATA_DIR}/weight.png"

# Color usage: echocolor color bold/normal styled-text normal-text
echocolor() {
    case "$1" in
    red)
        if [[ "$2" == "bold" ]]; then
            echo -e "\\e[1;31m$3\\e[0m$4"
        else
            echo -e "\\e[31m$3\\e[0m$4"
        fi
        ;;
    green)
        if [[ "$2" == "bold" ]]; then
            echo -e "\\e[1;32m$3\\e[0m$4"
        else
            echo -e "\\e[32m$3\\e[0m$4"
        fi
        ;;
    yellow)
        if [[ "$2" == "bold" ]]; then
            echo -e "\\e[1;33m$3\\e[0m$4"
        else
            echo -e "\\e[33m$3\\e[0m$4"
        fi
        ;;
    blue)
        if [[ "$2" == "bold" ]]; then
            echo -e "\\e[1;34m$3\\e[0m$4"
        else
            echo -e "\\e[34m$3\\e[0m$4"
        fi
        ;;
    esac
}

helps() {
    echo "Weight.sh body mass monitoring script. Draws graphs with gnuplot."
    echocolor "green" "normal" "Usage:" " weight.sh <what-to-do>"
    echo "Where <what-to-do> is one of:"
    echo "-c   create new entry interactively"
    echo "-p   print summary and draw graph to terminal"
    echo "-i   print summary and open graph image"
}

echoBanner() {
    echo -e "
[0;1;35;95mⓌ[0m [0;1;31;91mⒺ[0m [0;1;33;93mⒾ[0m [0;1;32;92mⒼ[0m [0;1;36;96mⒽ[0m [0;1;34;94mⓉ[0m [0;1;35;95mⓈ[0m [0;1;31;91mⒸ[0m [0;1;33;93mⓇ[0m [0;1;32;92mⒾ[0m [0;1;36;96mⓅ[0m [0;1;34;94mⓉ[0m
"
}

dependencies() {
    if command -v gnuplot >/dev/null; then
        GNUPLOT_INSTALLED="true"
    else
        GNUPLOT_INSTALLED="false"
        echocolor "yellow" "normal" "Optional dependecy gnuplot not installed. Not drawing graphs."
    fi
    if command -v bc >/dev/null; then
        BC_INSTALLED="true"
    else
        BC_INSTALLED="false"
        echocolor "yellow" "normal" "Optional dependecy bc not installed. Not making calculations."
    fi
}

sortCSV() {
    if [[ -f "$CSV_FILE" ]]; then
        cp "$CSV_FILE" "$CSV_FILE_BACKUP"
        SORTED=$(sort -n -t"-" -k1 -k2 -k3 "$CSV_FILE")
        echo "$SORTED" >"$CSV_FILE"
    fi
}

initScript() {
    echoBanner
    dependencies

    if [[ ! -d "$DATA_DIR" ]]; then
        mkdir -v "$DATA_DIR"
    fi

    if [[ $# -ne 1 ]]; then
        helps
        exit 1
    fi
    case "$1" in
    -c | --create)
        createEntry
        ;;
    -p | --print)
        printSummary "terminal"
        ;;
    -i | --image)
        printSummary "image"
        ;;
    -h | -H | --help)
        helps
        exit 0
        ;;
    *)
        helps
        exit 1
        ;;
    esac
}

createEntry() {
    echocolor "blue" "bold" "Creating new weight entry"
    WEIGHTQUERY="Weight as decimal (example: 80.2): "
    printf "%s" "$WEIGHTQUERY"
    while read WEIGHT; do
        if [[ "$WEIGHT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            break
        else
            echocolor "red" "bold" "Wrong weight format"
            printf "%s" "$WEIGHTQUERY"
        fi
    done

    DATEQUERY="Date d.m.Y (example: 10.04.2020) (optional): "
    printf "%s" "$DATEQUERY"
    while read -r DATE; do
        DAY=$(echo "$DATE" | cut -d '.' -f 1)
        MONTH=$(echo "$DATE" | cut -d '.' -f 2)
        YEAR=$(echo "$DATE" | cut -d '.' -f 3)
        DATESTRING="$YEAR-$MONTH-$DAY"
        if date "+%Y-%m-%d" -d "$DATESTRING" >/dev/null 2>&1 || "$DATE" == ""; then
            DATE=$(date "+%Y-%m-%d" -d "$DATESTRING")
            break
        else
            echocolor "red" "bold" "Wrong date format"
            printf "%s" "$DATEQUERY"
        fi
    done

    if [[ "$DATE" == "" ]]; then
        DATE=$(date +%d.%m.%Y)
    fi

    if echo "$DATE,$WEIGHT" >>"$CSV_FILE"; then
        echocolor "blue" "normal" "Entry created successfully"
    else
        echocolor "red" "bold" "Something went wrong"
    fi

    printf "Print summary? (y/i/n) (i for image format): "
    read -r PRINTSUMMARY
    case $PRINTSUMMARY in
    [yY]) printSummary "terminal" ;;
    [iI]) printSummary "image" ;;
    *)
        sortCSV
        exit 0
        ;;
    esac
}

drawPlot() {
    PLOTCONFIG_TERMINAL="
        set terminal dumb
        "
    PLOTCONFIG_IMAGE="
        set terminal pngcairo size 967,500
        set output \"$OUTPUTIMAGE\"
        "
    PLOTCONFIG_BASE="
        set datafile separator \",\"
        set xdata time
        set timefmt \"%Y-%m-%d\"
        set format x \"%d.%m.\"
        set format y \"%.1s%cKG\"
        plot '$CSV_FILE' using 1:2 title \"Body mass development over time\" with lines
        "

    echo "$PLOTCONFIG_IMAGE$PLOTCONFIG_BASE" | gnuplot

    if [[ "$1" == "terminal" ]]; then
        echocolor "blue" "normal" "Drawing graph"
        echo "$PLOTCONFIG_TERMINAL$PLOTCONFIG_BASE" | gnuplot
    elif [[ "$1" == "image" ]]; then
        echocolor "blue" "normal" "Opening graph image"
        xdg-open "$OUTPUTIMAGE"
    fi
}

datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(((d1 - d2) / 86400))
}

printSummary() {
    sortCSV
    echocolor "blue" "bold" "Printing summary"
    if [[ "$GNUPLOT_INSTALLED" == "true" ]]; then
        drawPlot "$1"
    fi

    START=$(head -n1 "$CSV_FILE")
    START_KG=$(echo "$START" | cut -d ',' -f 2)
    START_DATE=$(echo "$START" | cut -d ',' -f 1)
    START_DATE_FORMATTED=$(date "+%d.%m.%Y" -d "$START_DATE")
    LATEST=$(tail -n1 "$CSV_FILE")
    LATEST_KG=$(echo "$LATEST" | cut -d ',' -f 2)
    LATEST_DATE=$(echo "$LATEST" | cut -d ',' -f 1)
    LATEST_DATE_FORMATTED=$(date "+%d.%m.%Y" -d "$LATEST_DATE")
    PREVIOUS=$(tail -n2 "$CSV_FILE" | head -n1)
    PREVIOUS_KG=$(echo "$PREVIOUS" | cut -d ',' -f 2)
    PREVIOUS_DATE=$(echo "$PREVIOUS" | cut -d ',' -f 1)
    PREVIOUS_DATE_FORMATTED=$(date "+%d.%m.%Y" -d "$PREVIOUS_DATE")

    HIGHEST=$(sort -t"," -k2 -nr "$CSV_FILE" | head -n1)
    HIGHEST_KG=$(echo "$HIGHEST" | cut -d ',' -f 2)
    HIGHEST_DATE=$(echo "$HIGHEST" | cut -d ',' -f 1)
    HIGHEST_DATE_FORMATTED=$(date "+%d.%m.%Y" -d "$HIGHEST_DATE")
    LOWEST=$(sort -t"," -k2 -n "$CSV_FILE" | head -n1)
    LOWEST_KG=$(echo "$LOWEST" | cut -d ',' -f 2)
    LOWEST_DATE=$(echo "$LOWEST" | cut -d ',' -f 1)
    LOWEST_DATE_FORMATTED=$(date "+%d.%m.%Y" -d "$LOWEST_DATE")
    FULL_DAYS=$(datediff "$LATEST_DATE" "$START_DATE")
    LATEST_PREVIOUS_DAYS=$(datediff "$LATEST_DATE" "$PREVIOUS_DATE")

    if [[ "$BC_INSTALLED" == "true" ]]; then
        DIF_HIGH_LOW=$(echo "$HIGHEST_KG-$LOWEST_KG" | bc)
        DIF_START_LOW=$(echo "$START_KG-$LOWEST_KG" | bc)
        DIF_START_LATEST=$(echo "$START_KG-$LATEST_KG" | bc)
        DIF_HIGH_LATEST=$(echo "$HIGHEST_KG-$LATEST_KG" | bc)
        DIF_LATEST_PREVIOUS=$(echo "$LATEST_KG-$PREVIOUS_KG" | bc)
        DIF_LATEST_PREVIOUS_ABSOLUTE=$(printf "
        define abs(i) {
            if (i < 0) return (-i)
            return (i)
        }
        abs(%s)
        " "$DIF_LATEST_PREVIOUS" | bc)
        LATEST_SMALLER_THAN_PREVIOUS=$(echo "$LATEST_KG<$PREVIOUS_KG" | bc)
    fi

    echocolor "green" "bold" "Summary:"
    echocolor "green" "normal" "Data from $START_DATE_FORMATTED to $LATEST_DATE_FORMATTED ($FULL_DAYS days)"
    if [[ "$BC_INSTALLED" == "true" ]]; then
        echocolor "green" "normal" "Start:...... $START_KG KG on $START_DATE_FORMATTED"
        echocolor "green" "normal" "Lowest:..... $LOWEST_KG KG on $LOWEST_DATE_FORMATTED"
        echo
        echocolor "green" "normal" "Previous:... $PREVIOUS_KG KG on $PREVIOUS_DATE_FORMATTED"
        echocolor "green" "normal" "Latest:..... $LATEST_KG KG on $LATEST_DATE_FORMATTED"
        if [[ "$DIF_HIGH_LOW" == "$DIF_START_LOW" ]]; then
            echo
            if [[ "$DIF_HIGH_LOW" == "$DIF_HIGH_LATEST" ]]; then
                echocolor "green" "normal" "🎉 Latest weight was all-time lowest 🎉"
                echocolor "green" "normal" "Weight loss from start:.................. $DIF_START_LOW KG"
            else
                echocolor "green" "normal" "Maximum weight loss:..................... $DIF_HIGH_LOW KG"
                echocolor "green" "normal" "Weight loss from start:.................. $DIF_START_LATEST KG"
            fi
        else
            echocolor "green" "normal" "Highest:.... $HIGHEST_KG KG on $HIGHEST_DATE_FORMATTED"
            echo
            echocolor "green" "normal" "Highest weight recorded later than start"
            if [[ "$DIF_HIGH_LOW" == "$DIF_HIGH_LATEST" ]]; then
                echocolor "green" "normal" "🎉 Latest weight was all-time lowest 🎉"
                echocolor "green" "normal" "Weight loss from start:................... $DIF_START_LOW KG"
                echocolor "green" "normal" "Weight loss from highest point:........... $DIF_HIGH_LOW KG"
            else
                echocolor "green" "normal" "Maximum weight loss from start:........... $DIF_START_LOW KG"
                echocolor "green" "normal" "Maximum weight loss from highest point:... $DIF_HIGH_LOW KG"
                echocolor "green" "normal" "Weight loss from start:................... $DIF_START_LATEST KG"
                echocolor "green" "normal" "Weight loss from highest point:........... $DIF_HIGH_LATEST KG"
            fi
        fi
        if [[ "$LATEST_SMALLER_THAN_PREVIOUS" -eq 1 ]]; then
            echocolor "green" "bold" "Weight loss from previous record:........ $DIF_LATEST_PREVIOUS_ABSOLUTE KG (day difference: $LATEST_PREVIOUS_DAYS days)"
        else
            echocolor "yellow" "bold" "Weight gain from previous record:........ $DIF_LATEST_PREVIOUS_ABSOLUTE KG (day difference: $LATEST_PREVIOUS_DAYS days)"
        fi
    else
        echocolor "green" "normal" "Start:      $START_KG KG on $START_DATE_FORMATTED"
        echocolor "green" "normal" "Previous:   $PREVIOUS_KG KG on $PREVIOUS_DATE_FORMATTED"
        echocolor "green" "normal" "Latest:     $LATEST_KG KG on $LATEST_DATE_FORMATTED"
        echo
        echocolor "green" "normal" "Highest:    $HIGHEST_KG KG on $HIGHEST_DATE_FORMATTED"
        echocolor "green" "normal" "Lowest:     $LOWEST_KG KG on $LOWEST_DATE_FORMATTED"
    fi
}

initScript "$1"
