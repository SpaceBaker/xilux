TODO: this markdown file explains how to use 'pkgm.sh' in conjonction with 'packages.json' to manage softwares/packages for your target system.

Exemple of a source 'packages.json'

{
    "packages": [
        {
            "name": "example-package",
            "version": "1.0.0",
            "git_url": "https://github.com/example/example-package.git",
            "download_url": "https://example.com/example-package/archive/",
            "download_method": "git",  // or "https", "ftp", etc.
			"configuring_cmd": [
				"configure",
                "--build=${BUILDMACHINE}",
				"--host=${CHOST}",
				"--without-selinux",
				"--disable-libcap",
				"--prefix=/usr"
			],
			"building_cmd": [
				"make",
				"-j$(nproc)"
			],
			"installing_cmd": [
				"make",
				"DESTDIR=${ROOT_DIR}",
				"install"
			]
        }
    ]
}
