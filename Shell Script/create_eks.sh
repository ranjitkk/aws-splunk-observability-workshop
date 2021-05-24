#!/bin/bash -x
sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo yum -y install jq gettext bash-completion moreutils
sudo yum install git -y
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set 
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION} 
aws configure get default.region
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
aws kms create-alias --alias-name alias/eksworkshop --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
sh ~/.bash_completion
echo "Creating input parms for eksworkshop yaml"
# Get default vpc values
export DEFAULT_VPCID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq '.Vpcs[0].VpcId')
# Get default vpc cidr
export DEFAULT_VPCCIDR=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq '.Vpcs[0].CidrBlock')
# Get default subnets
export DEFAULT_SUBNETAZ1=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[0].AvailabilityZone')
export DEFAULT_SUBNETID1=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[0].SubnetId')
export DEFAULT_SUBNETCIDR1=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[0].CidrBlock')
export DEFAULT_SUBNETAZ2=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[1].AvailabilityZone')
export DEFAULT_SUBNETID2=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[1].SubnetId')
export DEFAULT_SUBNETCIDR2=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[1].CidrBlock')
export DEFAULT_SUBNETAZ3=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[2].AvailabilityZone')
export DEFAULT_SUBNETID3=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[2].SubnetId')
export DEFAULT_SUBNETCIDR3=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$DEFAULT_VPCID | jq '.Subnets[2].CidrBlock')
# Checking if the values are properly set
echo $DEFAULT_SUBNETAZ1 $DEFAULT_SUBNETAZ2 $DEFAULT_SUBNETAZ3
echo $DEFAULT_SUBNETID1 $DEFAULT_SUBNETID2 $DEFAULT_SUBNETID3
echo $DEFAULT_SUBNETCIDR1 $DEFAULT_SUBNETCIDR2 $DEFAULT_SUBNETCIDR3
# Creating eksworksopy.yaml file
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

vpc:
  id: ${DEFAULT_VPCID}  # (optional, must match VPC ID used for each subnet below)
  cidr: ${DEFAULT_VPCCIDR}       # (optional, must match CIDR used by the given VPC)
  subnets:
    # must provide 'private' and/or 'public' subnets by availibility zone as shown
    private:
      ${DEFAULT_SUBNETAZ1}:
        id: ${DEFAULT_SUBNETID1}
        cidr: ${DEFAULT_SUBNETCIDR1} # (optional, must match CIDR used by the given subnet)

      ${DEFAULT_SUBNETAZ2}:
        id: ${DEFAULT_SUBNETID2}
        cidr: ${DEFAULT_SUBNETCIDR2} # (optional, must match CIDR used by the given subnet)

      ${DEFAULT_SUBNETAZ3}:
        id: ${DEFAULT_SUBNETID3}
        cidr: ${DEFAULT_SUBNETCIDR3} # (optional, must match CIDR used by the given subnet)

managedNodeGroups:
- name: nodegroup
  instanceType: t3.small
  desiredCapacity: 2
  iam:
    withAddonPolicies:
      albIngress: true
  privateNetworking: true    
secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF
