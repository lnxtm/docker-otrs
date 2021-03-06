FROM ubuntu:16.04

ENV OTRS_VERSION 3.3.6
ENV OTRS_HOME /opt/otrs

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		wget \
	&& wget --progress=bar:force http://ftp.otrs.org/pub/otrs/otrs-${OTRS_VERSION}.tar.gz \
	&& mkdir -p ${OTRS_HOME} \
	&& echo "Extracting OTRS archive otrs-${OTRS_VERSION}.tar.gz" \
	&& tar -xzf otrs-${OTRS_VERSION}.tar.gz -C ${OTRS_HOME} --strip 1 \
	&& echo "Extraction finished" \
	&& rm -rf /var/lib/apt/lists/* otrs-${OTRS_VERSION}.tar.gz

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		apache2 \
		cron \
		libapache2-mod-perl2 \
		libarchive-zip-perl \
		libauthen-sasl-perl \
		libcrypt-eksblowfish-perl \
		libcrypt-ssleay-perl \
		libdbd-mysql-perl \
		libdbi-perl \
		libdigest-md5-perl \
		libio-socket-ssl-perl \
		libjson-xs-perl \
		libmail-imapclient-perl \
		libmime-base64-perl \
		libnet-dns-perl \
		libnet-ldap-perl \
		libtemplate-perl \
		libtext-csv-xs-perl \
		libtimedate-perl \
		libxml-libxml-perl \
		libxml-libxslt-perl \
		libxml-parser-perl \
		libyaml-libyaml-perl \
		wget \
	&& rm -rf /var/lib/apt/lists/*

ENV ENTRYPOINT_FILE /usr/local/sbin/entrypoint.sh

RUN a2dismod mpm_event mpm_worker \
	&& a2enmod mpm_worker perl filter deflate headers \
	&& ln -s ${OTRS_HOME}/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/zzz_otrs.conf \
	&& a2ensite zzz_otrs

COPY entrypoint.sh ${ENTRYPOINT_FILE}
COPY 000-default.conf /etc/apache2/sites-available/
COPY ports.conf /etc/apache2/
RUN cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
RUN useradd -G www-data -d ${OTRS_HOME} otrs \

	&& chown www-data:www-data ${ENTRYPOINT_FILE} \
	&& chmod 554 ${ENTRYPOINT_FILE} \
	&& ln -s ${ENTRYPOINT_FILE} /entrypoint.sh

CMD ["entrypoint.sh"]
