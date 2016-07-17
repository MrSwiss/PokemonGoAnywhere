
OPTOOL="./optool"

COMMAND=$1
IPA=$2
MOBILEPROVISION=$3
DEV_CERT_NAME="iPhone Developer"
CODESIGN_NAME=`security dump-keychain login.keychain|grep "$DEV_CERT_NAME"|head -n1|cut -f4 -d \"|cut -f1 -d\"`
TMPDIR=".patchapp.cache"
DYLIB=PokemonGoAnywhere.dylib

#
# Usage / syntax
#
function usage {
	if [ "$2" == "" -o "$1" == "" ]; then
		cat <<USAGE
Syntax: $0 <command> </path/to/your/ipa/file.ipa> [/path/to/your/file.mobileprovision]"
Where 'command' is one of:"
	info  - Show the information required to create a Provisioning Profile
	        that matches the specified .ipa file
	patch - Inject the current Theos tweak into the specified .ipa file.
	        Requires that you specify a .mobileprovision file.

USAGE
	fi
}

#
# Setup all the things.
#
function setup_environment {
	if [ "$IPA" == "" ]; then
		usage
		exit 1
	fi
	if [ ! -r "$IPA" ]; then
		echo "$IPA not found or not readable"
		exit 1
	fi

	# setup
	rm -rf "$TMPDIR" >/dev/null 2>&1
	mkdir "$TMPDIR"
	SAVED_PATH=`pwd`

	# uncompress the IPA into tmpdir
	echo '[+] Unpacking the .ipa file ('"`pwd`/$IPA"')...'
	unzip -o -d "$TMPDIR" "$IPA" >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Couldn't unzip the IPA file."
		exit 1
	fi

	cd "$TMPDIR"
	cd Payload/*.app
	if [ "$?" != "0" ]; then
		echo "Couldn't change into Payload folder. Wat."
		exit 1
	fi
	APP=`pwd`
	APP=${APP##*/}
	APPDIR=$TMPDIR/Payload/$APP
	cd "$SAVED_PATH"
	BUNDLE_ID=`plutil -convert xml1 -o - $APPDIR/Info.plist|grep -A1 CFBundleIdentifier|tail -n1|cut -f2 -d\>|cut -f1 -d\<`-patched
	APP_BINARY=`plutil -convert xml1 -o - $APPDIR/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`

}

#
# Show the user the information necessary to generate a .mobileprovision
#
function ipa_info {

echo 'removed'
}

#
# Inject the current Theos tweak into the specified .ipa file
#
function ipa_patch {

	setup_environment

	if [ "$MOBILEPROVISION" == "" ]; then
		usage
		exit 1
	fi
	if [ ! -r "$MOBILEPROVISION" ]; then
		echo "Can't read $MOBILEPROVISION"
		exit 1
	fi

	if [ ! -x "$OPTOOL" ]; then
		echo "You need to install optool from here: https://github.com/alexzielenski/optool"
		echo "Then update OPTOOL variable in '$0' to reflect the correct path to the optool binary."
		exit 1
	fi

	DEVELOPER_ID=`security dump-keychain login.keychain|grep "iPhone Distribution"|head -n1|cut -f2 -d \(|cut -f1 -d\)`
	if [ "$?" != "0" ]; then
		echo "Error getting Apple \"iPhone Developer\" certificate ID."
		exit 1
	fi

	# copy the files into the .app folder
	echo '[+] Copying .dylib dependences into "'$TMPDIR/Payload/$APP'"'
	cp "$DYLIB" $TMPDIR/Payload/$APP/
	cp CydiaSubstrate $TMPDIR/Payload/$APP/

	# sign all of the .dylib files we're injecting into the app
	echo '[+] Codesigning .dylib dependencies with certificate "'$CODESIGN_NAME'"'
	for file in "$APPDIR/${DYLIB##*/}" "$APPDIR/CydiaSubstrate" "$DYLIB"; do
		echo '     '$file
		codesign -fs "$CODESIGN_NAME" "$file" >& /dev/null
		if [ "$?" != "0" ]; then
			echo "Codesign failed. Have you ran 'make' yet?"
			exit 1
		fi
	done
	
	# re-sign Frameworks, too
	for file in `ls -1 $APPDIR/Frameworks/*`; do
		echo -n '     '
		codesign -fs "$CODESIGN_NAME" --entitlements entitlements.xml $file
	done

	# patch the app to load the new .dylib (sames a _backup file)
	echo '[+] Patching "'$APPDIR/$APP_BINARY'" to load "'${DYLIB##*/}'"'
	if [ "$?" != "0" ]; then
		echo "Failed to grab executable name from Info.plist. Debugging required."
		exit 1
	fi
	$OPTOOL install -c load -p "@executable_path/"${DYLIB##*/} -t $APPDIR/$APP_BINARY >& /dev/null
	if [ "$?" != "0" ]; then
		echo "Failed to inject "${DYLIB##*/}" into $APPDIR/${APP_BINARY}. Can I interest you in debugging the problem?"
		exit 1
	fi
	chmod +x "$APPDIR/$APP_BINARY"

	# generate the correct entitlements
	echo '[+] Generating entitlements.xml for distribution ID '$DEVELOPER_ID
	cat <<XML > entitlements.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
XML
	strings "$MOBILEPROVISION" | sed -e '1,/<key>Entitlements<\/key>/d' -e '/<\/dict>/,$d' >> entitlements.xml
	echo "</dict></plist>" >> entitlements.xml


	# re-sign the .app
	echo '[+] Codesigning the patched .app bundle with certificate "'$CODESIGN_NAME'"'
	cd $TMPDIR/Payload
	echo -n '     '
	codesign -fs "$CODESIGN_NAME" --deep --entitlements ../../entitlements.xml $APP
	if [ "$?" != "0" ]; then
		cd ..
		echo "Failed to sign $APP with entitlements.xml. You're on your own, sorry."
		exit 1
	fi
	cd ..
	
	# re-pack the .ipa
	echo '[+] Repacking the .ipa'
	rm -f "${IPA%*.ipa}-patched.ipa" >/dev/null 2>&1
	zip -9r "${IPA%*.ipa}-patched.ipa" Payload/ >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Failed to compress the app into an .ipa file."
		exit 1
	fi
	IPA=${IPA#../*}
	mv "${IPA%*.ipa}-patched.ipa" ..
	echo "[+] Wrote \"${IPA%*.ipa}-patched.ipa\""
	echo "[+] Great success!"
	cd - >/dev/null 2>&1
}

#
# Main
#
case $COMMAND in
	info)
		ipa_info
		;;
	patch)
		ipa_patch
		;;
	*)
		usage
		exit 1
		;;
esac
	
# success!
exit 0

