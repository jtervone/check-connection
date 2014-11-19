#!/bin/bash

LOG_DIR="/home/$(whoami)/log/check-connection/"
GATEWAY="192.168.1.1"
DNS="8.8.8.8"
URLS="http://google.com/ http://bing.com/ http://yahoo.com/"

LOG_FILE="${LOG_DIR}$(date +"%Y-%m-%d").log"
START=$(date +"%Y-%m-%d %H:%M")

for URL in ${URLS}
do
	OUTPUT=$(wget -q --timeout=20 --spider --tries=10 ${URL} 2>&1)

	if [ $? -ne 0 ]; then
		# $URL is not responding
		OUTPUT=$(ping -q -t50 -w1 -c1 ${DNS} 2>&1)
		if [ $? -eq 0 ]; then
			# DNS server is responding
			echo "${START} 0 1 1 ERROR DNS not responding" >> "${LOG_FILE}"
		else
			# If gateway is defined
			if [ ${#GATEWAY} -gt 0 ]; then
				OUTPUT=$(wget -q --timeout=20 --spider --tries=10 ${GATEWAY} 2>&1)
				if [ $? -ne 0 ]; then
					# Gateway is not responding
					echo "${START} 0 0 0 ERROR Gateway not responding" >> "${LOG_FILE}"
				else
					# Gateway responds but DNS server is not responding
					echo "${START} 0 0 1 ERROR Gateway OK but DNS not responding" >> "${LOG_FILE}"
				fi
			else
				# DNS server is not responding
				echo "${START} 0 1 1 ERROR DNS not responding" >> "${LOG_FILE}"
			fi
		fi
	else
		# $URL is responding
		echo "${START} 1 1 1 OK URL ${URL} responding" >> "${LOG_FILE}"
		break
	fi
done
