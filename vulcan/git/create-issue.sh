# /vulcan/github_cli/create-issue.sh
#!/bin/bash

# exist dependency
wget -q https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux32 -O /jq && chmod +x /jq

_write_fl_info_in_issue() {
	VULCAN_ISSUE_FL_CONTENTS=""
	VULCAN_TRIGGER_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/blob/$GITHUB_SHA"
	/jq 'sort_by(.[2]) | reverse' $VULCAN_OUTPUT_DIR/fl.json > $VULCAN_OUTPUT_DIR/fl_sortby_score.json
	for i in {0..4}
	do
		ithFL=$(sh -c "/jq '.[$i]' $VULCAN_OUTPUT_DIR/fl_sortby_score.json")
		buggy_source=$(echo $ithFL | /jq -r '.[0]')
		buggy_line=$(echo $ithFL | /jq '.[1]')
		buggy_score=$(echo $ithFL | /jq '.[2]')
		
		VULCAN_ISSUE_FL_CONTENTS=$( \
			printf "\n\n----$VULCAN_ISSUE_FL_CONTENTS\n%s/%s#L%d\nSuspicious score: %.2f" \
			$VULCAN_TRIGGER_URL \
			$buggy_source \
			$buggy_line \
			$buggy_score \
		)
	done
}

_create_issue() {
	echo ==========Creating Issue==========
	COMMAND="gh issue create \
	-t \"Vulcan\" \
	-b \"This issue is generated by Vulcan for commit: $GITHUB_SHA
	Top 5 fault localization results
	$VULCAN_ISSUE_FL_CONTENTS\" \
	|| true"
	echo $COMMAND
	EXECUTE_ISSUE_COMMAND=$(sh -c "$COMMAND")
	echo $EXECUTE_ISSUE_COMMAND
	echo ==================================
}

_write_fl_info_in_issue
_create_issue
