#!/usr/bin/env bash
git clone https://github.com/JeroenVanDerLaan/pimcore-boilerplate.git 5.8
rm -rf ./5.8/.git
rm -rf ./5.8/.gitignore

cp ./install-base.sh 5.8/app/Resources/docker/install.sh
cp ./services.yml 5.8/app/Resources/docker/services.yml

cd 5.8
./app/Resources/docker/install.sh
cd ..

declare -a versions
versions[0]=5.4.0
versions[1]=5.4.1
versions[2]=5.4.2
versions[3]=5.4.3
versions[4]=5.4.4
versions[5]=5.5.0
versions[6]=5.5.1
versions[7]=5.5.2
versions[8]=5.5.3
versions[9]=5.5.4
versions[10]=5.6.0
versions[11]=5.6.1
versions[12]=5.6.2
versions[13]=5.6.3
versions[14]=5.6.4
versions[15]=5.6.5
versions[16]=5.6.6
versions[17]=5.7.0
versions[18]=5.7.1
versions[19]=5.7.2
versions[20]=5.7.3
versions[21]=5.8.0
versions[22]=5.8.1
versions[23]=5.8.2

for i in "${versions[@]}"; do
    mkdir -p $i;
done
for i in "${versions[@]}"; do
    cp -r 5.8/. $i
    sed "s/\${PIMCORE_VERSION}/$i/g" composer-base.json > ./$i/composer.json
    cd $i
    ./app/Resources/docker/install.sh
    cd ..
done
