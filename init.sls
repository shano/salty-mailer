mail-pkgs:
  pkg.installed:
    - pkgs:
      - postfix
      - sasl2-bin
      - libsasl2-2
      - procmail 
      - libsasl2-modules
      - dovecot-imapd
      - spamassassin
      - pyzor

# SpamAssassin
/etc/spamassassin/local.cf:
  file.managed:
    - mode: 644
    - source: salt://mail/spamassassin/local.cf

/etc/default/spamassassin:
  file.managed:
    - mode: 644
    - source: salt://mail/spamassassin/spamassassin


# Postfix
/etc/postfix/main.cf:
  file.managed:
    - mode: 644
    - source: salt://mail/postfix/main.cf

/etc/postfix/master.cf:
  file.managed:
    - mode: 644
    - source: salt://mail/postfix/master.cf

# dovecot
/etc/dovecot/conf.d/10-mail.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://mail/dovecot/conf.d/10-mail.conf

/etc/dovecot/conf.d/10-master.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://mail/dovecot/conf.d/10-master.conf

/etc/dovecot/conf.d/10-auth.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://mail/dovecot/conf.d/10-auth.conf

maildirmake.dovecot Maildir:
  cmd.run:
    - user: <username>
    - cwd: /home/<username>
    - unless: test -e Maildir
    - require:
      - pkg: mail-pkgs

{% for folder in pillar.get('mailfolders', {}) %}
maildirmake.dovecot /home/<username>/Maildir/.{{folder}}:
  cmd.run:
    - user: <username>
    - unless: test -e /home/<username>/Maildir/.{{folder}}
{% endfor %}

dovecot:
  service.running:
    - require:
      - cmd: maildirmake.dovecot Maildir
      - file: /etc/dovecot/conf.d/10-mail.conf

# Promail
/etc/procmailrc:
  file.managed:
    - mode: 644
    - source: salt://mail/procmail/procmailrc
