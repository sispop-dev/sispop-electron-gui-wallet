local docker_image = 'registry.oxen.rocks/lokinet-ci-nodejs';

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
          './tools/download-oxen-files.sh https://oxen.rocks/oxen-io/oxen-core/oxen-stable-linux-LATEST.tar.xz',
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
          './tools/download-oxen-files.sh https://oxen.rocks/oxen-io/oxen-core/oxen-stable-win-LATEST.zip',
          'wine bin/oxend.exe --version',
          'wine bin/oxen-wallet-rpc.exe --version',
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
          CSC_LINK: 'tools/macos-codesign-cert.p12',
          CSC_KEY_PASSWORD: { from_secret: 'CSC_KEY_PASSWORD' },
          SIGNING_APPLE_ID: { from_secret: 'SIGNING_APPLE_ID' },
          SIGNING_APP_PASSWORD: { from_secret: 'SIGNING_APP_PASSWORD' },
          SIGNING_TEAM_ID: 'SUQ8J2PCT7',
        },
        commands: [
          'echo "Building on ${DRONE_STAGE_MACHINE}"',
          './tools/download-oxen-files.sh https://oxen.rocks/oxen-io/oxen-core/oxen-stable-macos-LATEST.tar.xz',
          'if [ -z "$${SIGNING_APPLE_ID}" ]; then export CSC_IDENTITY_AUTO_DISCOVERY=false; fi',
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
