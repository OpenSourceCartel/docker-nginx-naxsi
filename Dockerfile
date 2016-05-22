FROM jkirkby91/ubuntusrvbase:latest
MAINTAINER James Kirkby <james.kirkby@sonyatv.com>

RUN apt-get update && \
apt-get upgrade -y && \
apt-get install nginx-naxsi fail2ban supervisor -y --force-yes --fix-missing && \
apt-get remove --purge -y software-properties-common build-essential && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

RUN cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

RUN touch /etc/fail2ban/filter.d/nginx-req-limit.conf

COPY confs/nginx-req-limit.conf /etc/fail2ban/filter.d/nginx-req-limit.conf

COPY confs/jail1.conf /tmp/jail.conf

RUN cat /tmp/jail.conf >> /etc/fail2ban/jail.local

RUN rm /tmp/jail.conf

COPY confs/nginx-naxsi.conf /etc/fail2ban/filter.d/nginx-naxsi.conf

COPY confs/jail2.conf /tmp/jail.conf

RUN cat /tmp/jail.conf >> /etc/fail2ban/jail.conf

# Copy supervisor conf
COPY confs/supervisord.conf /etc/supervisord.conf

RUN curl -O /etc/nginx/sites-avalible/rp.conf -sL https://gist.githubusercontent.com/jkirkby91/e6de5882f0e6df8e42adf1fb6f8e78b6/raw/5aafd3b95a2ac3b9617fad38adf593b7f6d44a76/nginx-ssl-loadbalancer-proxy-naxsi.conf

# Set entrypoint
CMD ["/usr/bin/supervisord", "-n -c /etc/supervisord.conf"]
