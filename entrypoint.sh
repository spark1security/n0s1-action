#!/bin/bash
set -e
while getopts "a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:z:" o; do
   case "${o}" in
       a)
         export scanTarget=${OPTARG}
       ;;
       b)
         export userEmail=${OPTARG}
       ;;
       c)
         export passwordKey=${OPTARG}
       ;;
       d)
         export platformURL=${OPTARG}
       ;;
       e)
         export postComment=${OPTARG}
       ;;
       f)
         export skipComment=${OPTARG}
       ;;
       g)
         export regexFile=${OPTARG}
       ;;
       h)
         export configFile=${OPTARG}
       ;;
       i)
         export reportFile=${OPTARG}
       ;;
  esac
done

export scanTarget="${scanTarget}"
export userEmail="${userEmail}"
export passwordKey="${passwordKey}"
export platformURL="${platformURL}"
export postComment="${postComment}"
export skipComment="${skipComment}"
export regexFile="${regexFile}"
export configFile="${configFile}"
export reportFile="${reportFile}"


ARGS=""
if [ $userEmail ];then
 ARGS="$ARGS --email $userEmail"
fi
if [ $passwordKey ];then
 ARGS="$ARGS --api-key $passwordKey"
fi
if [ $platformURL ];then
 ARGS="$ARGS --server $platformURL"
fi
if [ $postComment ];then
 ARGS="$ARGS --post-comment $postComment"
fi
if [ $skipComment ];then
 ARGS="$ARGS --skip-comment $skipComment"
fi
if [ $regexFile ];then
 ARGS="$ARGS --regex-file $regexFile"
fi
if [ $configFile ];then
 ARGS="$ARGS --config-file $configFile"
fi
if [ $reportFile ];then
 ARGS="$ARGS --report-file $reportFile"
else
 export reportFile="n0s1_report.json"
fi

echo "Running n0s1 with options: n0s1 ${scanTarget} ${ARGS}" | sed "s/$passwordKey/<REDACTED>/g"
n0s1 ${scanTarget} ${ARGS}
returnCode=$?

