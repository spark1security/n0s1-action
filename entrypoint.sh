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
       j)
         export secretManager=${OPTARG}
       ;;
       k)
         export contactHelp=${OPTARG}
       ;;
       l)
         export label=${OPTARG}
       ;;
       m)
         export showMatchedSecretOnLogs=${OPTARG}
       ;;
       n)
         export debug=${OPTARG}
       ;;
       o)
         export reportFormat=${OPTARG}
       ;;
       p)
         export timeout=${OPTARG}
       ;;
       q)
         export limit=${OPTARG}
       ;;
       r)
         export insecure=${OPTARG}
       ;;
       s)
         export map=${OPTARG}
       ;;
       t)
         export mapFile=${OPTARG}
       ;;
       u)
         export scope=${OPTARG}
       ;;
  esac
done

export scanTarget="${scanTarget}"
export userEmail="${userEmail}"
export passwordKey=$(echo "${passwordKey}" | tr -d " ")
export platformURL="${platformURL}"
export postComment="${postComment}"
export skipComment="${skipComment}"
export regexFile="${regexFile}"
export configFile="${configFile}"
export reportFile="${reportFile}"
export secretManager="${secretManager}"
export contactHelp="${contactHelp}"
export label="${label}"
export showMatchedSecretOnLogs="${showMatchedSecretOnLogs}"
export debug="${debug}"
export reportFormat="${reportFormat}"
export timeout="${timeout}"
export limit="${limit}"
export insecure="${insecure}"
export map="${map}"
export mapFile="${mapFile}"
export scope="${scope}"


ARGS=""
if [ $userEmail ];then
 ARGS="$ARGS --email $userEmail"
fi
if [ $passwordKey ];then
 ARGS="$ARGS --api-key $passwordKey"
else
 export passwordKey="Warning! Password key will be loaded from environment variables."
fi
if [ $platformURL ];then
 ARGS="$ARGS --server $platformURL"
fi
if [ $postComment ];then
 ARGS="$ARGS --post-comment"
fi
if [ $skipComment ];then
 ARGS="$ARGS --skip-comment"
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
if [ $secretManager ];then
 ARGS="$ARGS --secret-manager $secretManager"
fi
if [ $contactHelp ];then
 ARGS="$ARGS --contact-help $contactHelp"
fi
if [ $label ];then
 ARGS="$ARGS --label $label"
fi
if [ $showMatchedSecretOnLogs ];then
 ARGS="$ARGS --show-matched-secret-on-logs"
fi
if [ $debug ];then
 ARGS="$ARGS --debug"
fi
if [ $reportFormat ];then
 ARGS="$ARGS --report-format $reportFormat"
fi
if [ $timeout ];then
 ARGS="$ARGS --timeout $timeout"
fi
if [ $limit ];then
 ARGS="$ARGS --limit $limit"
fi
if [ $insecure ];then
 ARGS="$ARGS --insecure"
fi
if [ $map ];then
 ARGS="$ARGS --map $map"
fi
if [ $mapFile ];then
 ARGS="$ARGS --map-file $mapFile"
fi
if [ $scope ];then
 ARGS="$ARGS --scope $scope"
fi

echo "Running n0s1 with options: n0s1 ${scanTarget} ${ARGS}" | sed "s/$passwordKey/<REDACTED>/g"
n0s1 ${scanTarget} ${ARGS}
returnCode=$?

