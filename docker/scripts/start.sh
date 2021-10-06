if [ -t 1 ]; then
    # TTY mode
    exec jupyter lab --ip='0.0.0.0' --port=8888 --no-browser &
    /bin/bash
else
    # Headless mode
    exec jupyter lab --ip='0.0.0.0' --port=8888 --no-browser
fi
