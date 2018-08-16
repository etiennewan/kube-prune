#! /bin/bash

DELETE=false
NAMESPACE="--all-namespaces"
age_field_number="6"
name_field_number="2"
TIME=
PATTERN=

help () {
    echo $(basename "$0")' [-h | --help] [-n | --namespace <namespace>] [-t | --time <time>] [-p | --pattern <pattern>] [--confirm-deletion]'
    echo ''
    echo 'Filter pods by namespace, matching a pattern, or older than a given time, then delete them.'
    echo 'Uses kubectl. Make sure kubectl is installed, and that you can list your pods with `kubectl get pods --all-namespaces`.'
    echo ''
    echo 'Pods are deleted only when you specify --confirm-deletion, be sure you want to delete all listed pods.'
    echo 'It is safe to use this script without --confirm-deletion.'
    echo ''
    echo 'Usage:'
    echo '-h,--help           show this help text.'
    echo '-n,--namespace      set namespace, expects a string.'
    echo '-t,--time           list pods older than a given time, expects a string like 10s (10 seconds), 30m (30 minutes), 2h (2 hours) or 1d (one day).'
    echo '-p,--pattern        list pods matching a pattern, expects a string or a RegExp.'
    echo '--confirm-deletion  Delete pods. Be careful when using it!'
    exit 0
}

while true; do
  case "$1" in
    --confirm-deletion ) DELETE=true; shift ;;
    -h | --help ) help;;
    -n | --namespace ) NAMESPACE="-n $2"; age_field_number="5"; name_field_number="1"; shift 2;;
    -t | --time ) TIME="$2"; shift 2;;
    -p | --pattern ) PATTERN="$2"; shift 2;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

mapfile lines < <(kubectl get pods $NAMESPACE)

# HEADER
echo -n "${lines[0]}"

# RESULTS
RESULTS="${lines[*]:1}"

if [ $PATTERN ]; then
    RESULTS=$(echo "$RESULTS" | grep -E $PATTERN)
fi

if [ $TIME ]; then
    RESULTS_TIME=()

    units="smhd"
    given_time_unit=$(echo "$TIME" | grep -oE "[$units]")
    time_wo_unit=${TIME%$given_time_unit}
    bigger_units=${units#*$given_time_unit}

    while read -r each; do
        each_tr=$( echo "$each" | tr -s " ")
        age=$(echo "$each_tr" | cut -f $age_field_number -d ' ')
        given_age_unit=$(echo "$age" | grep -oE "[$units]")
        age_wo_unit=${age%$given_age_unit}
	if [ $age ]; then
            if [[ ! -z "$bigger_units" && ! -z $(echo "$age" | grep -oE "[$bigger_units]") ]] || [[ ! -z $(echo "$age" | grep -oE "[$given_time_unit]") && "$age_wo_unit" -ge "$time_wo_unit" ]]; then
                RESULTS_TIME+="$each\n"
            fi
        fi
    done <<< "${RESULTS[*]}"

    mapfile RESULTS < <(printf "$RESULTS_TIME")
fi


echo -e "${RESULTS[*]}"

if $DELETE; then
    echo -e "\nDeleting pods listed above ..."
    while read -r each; do
        each_tr=$( echo "$each" | tr -s " ")
        name=$(echo "$each_tr" | cut -f $name_field_number -d ' ')
        if [ $name ]; then
            echo "--> Deleting $name" 
            kubectl delete pod "$name" --now
        fi
    done <<< "${RESULTS[*]}"
fi
