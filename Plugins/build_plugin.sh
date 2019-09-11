#!/bin/sh

PLUGIN_ROOT=`dirname $0`
PLUGIN_ROOT=`cd "${PLUGIN_ROOT}"; pwd`

compile_plugin() {
	PROJECT_NAME=`basename $1`
	plugin_dir=$PLUGIN_ROOT/$PROJECT_NAME

	LIB_TARGET_NAME=${PROJECT_NAME}

	UNIVERSAL_OUTPUTFOLDER=${plugin_dir}

	CONFIGURATION=Debug

	BUILD_DIR=${plugin_dir}/build

	xcodebuild -project ${plugin_dir}/${PROJECT_NAME}.xcodeproj -target ${LIB_TARGET_NAME} ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos BUILD_DIR="${BUILD_DIR}"

	if [ $? -eq 0 ]; then
		xcodebuild -project ${plugin_dir}/${PROJECT_NAME}.xcodeproj -target ${LIB_TARGET_NAME} ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}"
	fi

	if [ $? -eq 0 ]; then
		mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

		lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}"/lib${LIB_TARGET_NAME}.a "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${LIB_TARGET_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${LIB_TARGET_NAME}.a"
	fi
}

echo $PLUGIN_ROOT

if [ $# -eq 0 ]; then
for plugindir in ${PLUGIN_ROOT}/HN669SDK_*
do
	PROJECT_NAME=`basename ${plugindir}`

	if [[ $PROJECT_NAME == *Template ]]; then
		continue
	fi

	compile_plugin $PROJECT_NAME

	if [ $? -eq 0 ]; then
		continue
	else
		read -p "Error when build ${PROJECT_NAME}, Press [Enter] key to exit, or [c] to continue" CONTINUE
		if [ "$CONTINUE" = "c" ]; then
			continue
		else
			break
		fi
	fi
done
else
	compile_plugin $*
fi
