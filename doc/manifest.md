TODO: this markdown file explains how to use/create a manifest file to add softwares/packages to your target system.

Exemple of a source 'manifest.json'

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
