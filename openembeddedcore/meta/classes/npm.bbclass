DEPENDS_prepend = "nodejs-native "
S = "${WORKDIR}/npmpkg"

npm_do_compile() {
	# changing the home directory to the working directory, the .npmrc will
	# be created in this directory
	export HOME=${WORKDIR}
	npm config set dev false
	npm set cache ${WORKDIR}/npm_cache
	# clear cache before every build
	npm cache clear
	# Install pkg into ${S} without going to the registry
	npm --arch=${TARGET_ARCH} --production --no-registry install
}

npm_do_install() {
	mkdir -p ${D}${libdir}/node_modules/${PN}/
	cp -a ${S}/* ${D}${libdir}/node_modules/${PN}/ --no-preserve=ownership
}

python populate_packages_prepend () {
    instdir = d.expand('${D}${libdir}/node_modules/${PN}')
    extrapackages = oe.package.npm_split_package_dirs(instdir)
    pkgnames = extrapackages.keys()
    d.prependVar('PACKAGES', '%s ' % ' '.join(pkgnames))
    for pkgname in pkgnames:
        pkgrelpath, pdata = extrapackages[pkgname]
        pkgpath = '${libdir}/node_modules/${PN}/' + pkgrelpath
        expanded_pkgname = d.expand(pkgname)
        d.setVar('FILES_%s' % expanded_pkgname, pkgpath)
        if pdata:
            version = pdata.get('version', None)
            if version:
                d.setVar('PKGV_%s' % expanded_pkgname, version.encode("utf8"))
            description = pdata.get('description', None)
            if description:
                d.setVar('SUMMARY_%s' % expanded_pkgname, description.replace(u"\u2018", "'").replace(u"\u2019", "'").encode("utf8"))
    d.appendVar('RDEPENDS_%s' % d.getVar('PN', True), ' %s' % ' '.join(pkgnames))
}

FILES_${PN} += " \
    ${libdir}/node_modules/${PN} \
"

EXPORT_FUNCTIONS do_compile do_install
