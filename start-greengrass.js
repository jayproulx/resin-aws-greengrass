#!/usr/bin/env nodejs6.10

var fs = require('fs'), spawn = require('child_process').spawn;
var configExample = require('example.config.json');

var certsPath = "/app/greengrass/certs";
var certPath = `${certsPath}/cert.pem`;
var privateKeyPath = `${certsPath}/private.key`;
var configPath = "/app/greengrass/config/config.json";

var cert = process.env.CERT;
var privateKey = process.env.PRIVATE_KEY;
var ggHost = process.env.GG_HOST;
var iotHost = process.env.IOT_HOST;
var thingArn = process.env.thingArn;

configExample.coreThing.ggHost = ggHost;
configExample.coreThing.iotHost = iotHost;
configExample.coreThing.thingArn = thingArn;

fs.writeFile(certPath, cert, (err) => {
    if (err) throw err;

    console.log(`Wrote certificate to ${certPath}`);

    fs.writeFile(privateKeyPath, privateKey, (err) => {
        if (err) throw err;

        console.log(`Wrote private key to ${privateKeyPath}`);

        fs.writeFile(configPath, JSON.stringify(configExample), (err) => {
            if (err) throw err;

            console.log(`Wrote config to ${configPath}`);
            console.dir(configExample);

            console.log("Starting greengrassd");

            spawn('greengrassd', ['start'], {
                stdio: 'ignore',
                detached: true
            }).unref();
        });
    });
});