set(VERSION 0.19.1)

# Get archive
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ngtcp2/ngtcp2/releases/download/v${VERSION}/ngtcp2-${VERSION}.tar.bz2"
    FILENAME "ngtcp2-${VERSION}.tar.bz2"
    SHA512 e4bfe87765784dab9f8863278c8e68b1bd5525cd164ca210a6638a504041835c06f7ce7613cff9290a82caac34887c88ee7b6c90615a68246a9107b516f92ce5
)

# Patches
set(PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/patches/0001-Use-find_package-for-boringssl.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/0002-Add-a-shared-ngtcp2_crypto_boringssl-target.patch
)

# Extract archive
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES ${PATCHES}
)

# Run CMake build
if (boringssl IN_LIST FEATURES)
    set(BUILD_OPTIONS -DENABLE_BORINGSSL=ON)
elseif (libressl IN_LIST FEATURES)
    set(BUILD_OPTIONS -DENABLE_OPENSSL=ON)
else ()
    message(FATAL_ERROR "No SSL backend specified")
endif ()

if (VCPKG_LIBRARY_LINKAGE MATCHES static)
    set(NGTCP2_SHARED_LIB OFF)
    set(NGTCP2_STATIC_LIB ON)
else ()
    set(NGTCP2_SHARED_LIB ON)
    set(NGTCP2_STATIC_LIB OFF)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${BUILD_OPTIONS}
        -DENABLE_SHARED_LIB=${NGTCP2_SHARED_LIB}
        -DENABLE_STATIC_LIB=${NGTCP2_STATIC_LIB}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Prepare distribution
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ngtcp2 RENAME copyright)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/ngtcp2/version ${VERSION})
