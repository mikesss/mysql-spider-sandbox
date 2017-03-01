FROM centos:7

# deps
RUN yum -y install cmake
RUN yum -y groupinstall "Development Tools"
RUN yum -y install ncurses-devel

# copy and extract spider source
COPY ./mysql-5.5.34-spider-3.2 /mysql-5.5.34-spider-3.2
WORKDIR /mysql-bld

# configure and build
RUN cmake /mysql-5.5.34-spider-3.2
RUN make
RUN make install

# post installation stuff
RUN groupadd mysql
RUN useradd -r -g mysql -s /bin/false mysql

WORKDIR /usr/local/mysql
RUN chown -R mysql .
RUN chgrp -R mysql .
RUN scripts/mysql_install_db --user=mysql
RUN chown -R root .
RUN chown -R mysql data

# init spider and other things
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# start mysql
EXPOSE 3306
CMD ["/usr/local/mysql/bin/mysqld_safe", "--user=mysql"]
