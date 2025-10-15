FROM quay.io/kairos/ubuntu:24.04-standard-amd64-generic-v3.5.3-k3s-v1.32.8-k3s1 AS build

RUN <<EOF
echo "Linux\n
S5build\n
$(ls /lib/modules)\n
#140~14.04.1-Ubuntu SMP Fri Feb 16 09:25:20 UTC 2018\n
x86_64\n
x86_64\n
x86_64\n
GNU/Linux\n" > /etc/uname.txt
EOF

RUN apt update
RUN echo $(uname -r)
RUN apt install build-essential net-tools linux-headers-$(ls /lib/modules) -y


COPY driver .
COPY --chmod=0755 uname /usr/bin/uname

RUN make all

FROM quay.io/kairos/ubuntu:24.04-standard-amd64-generic-v3.5.3-k3s-v1.32.8-k3s1
ENV KDST="/lib/modules/*/kernel/drivers/net/ethernet/motorcomm/yt6801.ko"

COPY --from=build ${KDST} .

RUN mkdir -p "/lib/modules/$(ls /lib/modules)/kernel/drivers/net/ethernet/motorcomm/" && mv yt6801.ko "/lib/modules/$(ls /lib/modules)/kernel/drivers/net/ethernet/motorcomm/yt6801.ko"
RUN cat <<EOF > /etc/dracut.conf.d/yt6801.conf
add_drivers+=" yt6801 "
EOF

#RUN sudo dracut -f --omit "livenet dmsquash-live network systemd-networkd network-legacy" /boot/initramfs-$(uname -r).img $(uname -r)

