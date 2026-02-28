#!/usr/bin/env bash

set -euo pipefail

OWNER=${1:-sebastienrousseau}
BASE_DIR=${2:-"$HOME/Code"}
LIMIT=${3:-1000}

normalize_language() {
	local lang="$1"

	if [[ -z "$lang" ]]; then
		lang="Other"
	else
		case "$lang" in
		"C#") lang="CSharp" ;;
		"C++") lang="Cpp" ;;
		esac
	fi

	lang="${lang// /_}"
	lang="${lang//\//_}"
	echo "$lang"
}

normalize_visibility() {
	if [[ "$1" == "PRIVATE" ]]; then
		echo "Private"
	else
		echo "Public"
	fi
}

mkdir -p "$BASE_DIR"

cloned=0
existing=0
moved=0
failed=0

cleanup_empty_legacy_language_folders() {
	shopt -s dotglob nullglob
	for folder in "$BASE_DIR"/*; do
		if [[ ! -d "$folder" ]]; then
			continue
		fi

		base="$(basename "$folder")"
		if [[ "$base" == "Public" || "$base" == "Private" ]]; then
			continue
		fi

		entries=("$folder"/*)
		if ((${#entries[@]} == 0)); then
			rmdir "$folder"
			echo "Removed empty folder: $folder"
		fi
	done
}

while IFS=$'\t' read -r name lang visibility; do
	lang_dir="$(normalize_language "$lang")"
	visibility_dir="$(normalize_visibility "$visibility")"
	legacy_dir="$BASE_DIR/$lang_dir/$name"
	target_dir="$BASE_DIR/$visibility_dir/$lang_dir/$name"

	mkdir -p "$BASE_DIR/$visibility_dir/$lang_dir"

	if [[ -d "$target_dir" ]]; then
		existing=$((existing + 1))
		continue
	fi

	if [[ -d "$legacy_dir" ]]; then
		if mv "$legacy_dir" "$target_dir"; then
			moved=$((moved + 1))
		else
			failed=$((failed + 1))
			echo "FAILED MOVE: $OWNER/$name (left at: $legacy_dir)"
		fi
		continue
	fi

	echo "Cloning $OWNER/$name -> $visibility_dir/$lang_dir"

	if ! git clone "https://github.com/$OWNER/$name.git" "$target_dir"; then
		echo "FAILED: $OWNER/$name (left at: $target_dir)"
		failed=$((failed + 1))
		continue
	fi

	cloned=$((cloned + 1))
done < <(
	gh repo list "$OWNER" --limit "$LIMIT" --json name,primaryLanguage,visibility \
		--jq '.[] | [.name, (.primaryLanguage.name // "Other"), .visibility] | @tsv'
)

cleanup_empty_legacy_language_folders

if [[ "$failed" -gt 0 ]]; then
	echo "Done. Cloned $cloned repos, moved $moved existing repos, kept $existing repos, $failed failures."
else
	echo "Done. Cloned $cloned repos, moved $moved existing repos, kept $existing repos."
fi
