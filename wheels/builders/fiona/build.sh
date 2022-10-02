source wheels/builders/fiona/env_vars.sh
echo "enviroment variables"
env
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  # webp, zstd, xz, libtiff cause a conflict with building webp and libtiff
  # curl from brew requires zstd, use system curl
  # if php is installed, brew tries to reinstall these after installing openblas
  brew remove --ignore-dependencies webp zstd xz libtiff php curl
fi

echo "::group::Install a virtualenv"
  pwd
  ls -lrt
  source wheels/builders/fiona/multibuild/common_utils.sh
  source wheels/builders/fiona/multibuild/travis_steps.sh
  python3 -m pip install virtualenv
  before_install
echo "::endgroup::"

echo "::group::Build Library"
  pwd
  bash -x wheels/builders/fiona/multibuild/library_builders.sh
echo "::endgroup::"

echo "::group::Build wheel"
  pwd
  gh_clone $REPO_GIT $BUILD_COMMIT
  build_wheel $REPO_DIR $PLAT
  ls -l "${GITHUB_WORKSPACE}/${WHEEL_SDIR}/"
echo "::endgroup::"

if [[ $MACOSX_DEPLOYMENT_TARGET != "11.0" ]]; then
  echo "::group::Test wheel"
    install_run $PLAT
  echo "::endgroup::"
fi
