
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  # webp, zstd, xz, libtiff cause a conflict with building webp and libtiff
  # curl from brew requires zstd, use system curl
  # if php is installed, brew tries to reinstall these after installing openblas
  brew remove --ignore-dependencies webp zstd xz libtiff php
fi

echo "::group::Install a virtualenv"
  pwd
  ls -lrt
  source /wheels/builders/fiona/multibuild/common_utils.sh
  source /wheels/builders/fiona/multibuild/travis_steps.sh
  python3 -m pip install virtualenv
  before_install
echo "::endgroup::"

echo "::group::Build wheel"
  clean_code $REPO_DIR $BUILD_COMMIT
  build_wheel $REPO_DIR $PLAT
  ls -l "${GITHUB_WORKSPACE}/${WHEEL_SDIR}/"
echo "::endgroup::"

if [[ $MACOSX_DEPLOYMENT_TARGET != "11.0" ]]; then
  echo "::group::Test wheel"
    install_run $PLAT
  echo "::endgroup::"
fi
