## AMI Control

### Sharing AMI with another account

If you need to share a specific AMI with another account you can use this function:

```.\amicontrol.ps1 -ctrl {share/remove/delete/query} -ami {AMI ID} -account {account ID} -snap {snapshot ID} -profile {AWS Profile name}```

e.g.
```.\amicontrol.ps1 -ctrl share -ami ami-1234567 -account 4567890 -profile companyaws```

[AMI Control Script](./amicontrol.ps1)



#### Script Options

| Command Option | Description |
| -------------- | :-----------: |
|**-ctrl share** | Share an AMI with another account by adding permissions; specify the ami and account you wish to share with|
|**-ctrl remove** | Remove permissions to access the AMI; specify the ami and account you wish to remove from the share options.|
|**-ctrl delete** | Delete an AMI and it's associated Snapshots if they are not currently in use. *Note: This will not delete AMI's that are in use or in an off-state*|
|**-ctrl query** | Query an AMI for the associated AMI and snapshot information. Specify the AMI ID |
|**-ctrl reset** | Reset all permissions and remove sharing options ( Panic default mode )|
|**-awsprofile** | The AWS Profile on your machine to use ( default is specified if no other option provided ) based on your stored aws profiles |
|**-snap** | Provide a specific snapshot ID for removal |
|**-account** | Provide the Account ID for which you want to add or remove permissions from the image |