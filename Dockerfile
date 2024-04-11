FROM php:8.0-cli-alpine

# Install PHP CodeSniffer
ARG PHPCS_RELEASE="3.6.0"
RUN pear install PHP_CodeSniffer-$PHPCS_RELEASE

# Install the PHPCompatibility standard
ARG PHPCOMP_RELEASE="9.3.5"
RUN set -eux &&\
    apk --no-cache add git &&\
    mkdir -p "/opt/" &&\
    cd "/opt/" &&\
    git clone -v --single-branch --depth 1 https://github.com/PHPCompatibility/PHPCompatibility.git --branch $PHPCOMP_RELEASE &&\
    rm -rf PHPCompatibility/.git &&\
    apk del git

# Configure phpcs defaults
RUN phpcs --config-set installed_paths /opt/PHPCompatibility &&\
    phpcs --config-set default_standard PHPCompatibility &&\
    phpcs --config-set testVersion 8.0 &&\
    phpcs --config-set report_width 120

# Configure PHP with all the memory we might need (unlimited)
RUN echo "memory_limit = -1" >> /usr/local/etc/php/conf.d/memory.ini

WORKDIR /mnt/src

ENTRYPOINT ["/usr/local/bin/phpcs"]

CMD ["-p", "--colors", "."]
