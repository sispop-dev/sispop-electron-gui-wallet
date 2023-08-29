local docker_image = 'registry.download.sispop.site/lokinet-ci-nodejs';

local apt_get_quiet = 'apt-get -o=Dpkg::Use-Pty=0 -q';

[
  {
    kind: 'pipeline',
    type: 'docker',
    name: 'Linux (amd64)',
    platform: { arch: 'amd64' },
    steps: [
      {
        name: 'build',
        image: docker_image,
        environment: {
          SSH_KEY: { from_secret: 'SSH_KEY' },
          NODE_OPTIONS: '--openssl-legacy-provider',
        },
        commands: [
          'echo "Building on ${DRONE_STAGE_MACHINE}"',
          'echo "man-db man-db/auto-update boolean false" | debconf-set-selections',
          apt_get_quiet + ' update',
          apt_get_quiet + ' install -y eatmydata',
          'eatmydata ' + apt_get_quiet + ' dist-upgrade -y',
          './tools/download-sispop-files.sh https://download.sispop.site/sispop.site/sispop-core/sispop-stable-linux-LATEST.tar.xz',
          'npm --version',
          'node --version',
          'mkdir -p $CCACHE_DIR/electron-builder',
          'mkdir -p $CCACHE_DIR/npm',
          'npm ci --cache $CCACHE_DIR/npm',
          'ELECTRON_BUILDER_CACHE=$CCACHE_DIR/electron-builder npm --cache $CCACHE_DIR/npm run build',
          './tools/ci-drone-static-upload.sh',
        ],
      },
    ],
  },

  {
    kind: 'pipeline',
    type: 'docker',
    name: 'Windows (x64)',
    platform: { arch: 'amd64' },
    steps: [
      {
        name: 'build',
        image: docker_image,
        environment: {
          SSH_KEY: { from_secret: 'SSH_KEY' },
          WINEDEBUG: '-all',
          NODE_OPTIONS: '--openssl-legacy-provider',
        },
        commands: [
          'echo "Building on ${DRONE_STAGE_MACHINE}"',
          'echo "man-db man-db/auto-update boolean false" | debconf-set-selections',
          apt_get_quiet + ' update',
          apt_get_quiet + ' install -y eatmydata zip',
          'eatmydata ' + apt_get_quiet + ' dist-upgrade -y',
          './tools/download-sispop-files.sh https://download.sispop.site/sispop.site/sispop-core/sispop-stable-win-LATEST.zip',
          'wine bin/sispopd.exe --version',
          'wine bin/sispop-wallet-rpc.exe --version',
          'npm --version',
          'node --version',
          'mkdir -p $CCACHE_DIR/electron-builder',
          'mkdir -p $CCACHE_DIR/npm',
          'npm ci --cache $CCACHE_DIR/npm',
          'ELECTRON_BUILDER_CACHE=$CCACHE_DIR/electron-builder npm --cache $CCACHE_DIR/npm run windows',
          './tools/ci-drone-static-upload.sh',
        ],
      },
    ],
  },

  {
    kind: 'pipeline',
    type: 'exec',
    name: 'MacOS (unsigned)',
    platform: { os: 'darwin', arch: 'amd64' },
    steps: [
      {
        name: 'build',
        environment: {
          SSH_KEY: { from_secret: 'SSH_KEY' },
          CSC_IDENTITY_AUTO_DISCOVERY: 'false',
        },
        commands: [
          'echo "Building on ${DRONE_STAGE_MACHINE}"',
          './tools/download-sispop-files.sh https://download.sispop.site/sispop.site/sispop-core/sispop-stable-macos-LATEST.tar.xz',
          'npm --version',
          'node --version',
          'mkdir -p $CCACHE_DIR/electron-builder',
          'mkdir -p $CCACHE_DIR/npm',
          'npm ci --cache $CCACHE_DIR/npm',
          'ELECTRON_BUILDER_CACHE=$CCACHE_DIR/electron-builder WINEDEBUG=-all npm --cache $CCACHE_DIR/npm run build',
          './tools/ci-drone-static-upload.sh',
        ],
      },
    ],
  },

]
