#### BASIC 3 NIC BIGIP TERRAFORM ANSIBLE DEPLOYMENT ###

This is a basic 3 NIC Big IP deployment using Terraform and Ansible. This uses a two step configuration approach where you build the foundational infrastructure (the ec2 big-ip instance) first w/ terraform and then configure the TMOS level configurations with Ansible.  I hope to improve on this workflow as my knowledge and experience grows with each platform (terraform and ansible). You will need the following to run this..

1. Terraform https://www.terraform.io/downloads.html (this can be installed on a control server in AWS)
2. AWS Gov Console account that has privs to deploy ec2 instances in your AWSGov account
3. Access Key and Secret Key for account Terraform will use
4. SSH Key for initial login to the Big-IP after you deploy the initial EC2(Big-IP) instance.
5. Ansible (this can be installed on a control server in AWS 'yum install ansible -y', make sure ansible is installed  on the same server as terraform)
6. Big-IP Ansible module follow the instructions here https://clouddocs.f5.com/products/orchestration/ansible/devel/usage/virtualenv.html

To prep terraform:
1. change the variables in the file  awsGov_singleF5_tf_ansible_3nic/tf/modules/aws/variables.tf to suit your environment
2. place the public and  private key in awsGov_singleF5_tf_ansible_3nic/tf/keys used to deploy the big-ip in aws

To run terraform:
Start in the directory awsGov_singleF5_tf_ansible_3nic
1. cd tf
2. run terraform init (this will initiate the terraform plan )
3. terraform apply --auto-approve
4. After the plan has run successfully, you will need to log into the deployed big ip via the ssh key you generated and change the admin password and/or create an account with admin privileges which will be used by ansible to make TMOS level configurations

To run ansible:
1. cd ../ansible
2. update the variables in group_vars/bigips.yaml to suite your environment
3. the hosts file should stay unchanged as "localhost" being the only listed host.  F5's ansible modules interacts with BigIps iControl interface over https unlike a majority of modules which use SSH.
4. the ansible.cfg file should stay the same also, but feel free review this file and see all configurations which can be altered.  A majority are commented out using the default setting
5. run the ansible playbook with the following command "ansible-playbook f5Setup.yaml" watch your big-ip get configured!
6. once the playbook finishes deploying, you should have a bigip fully licensed and configured with selfips


This is a very very very basic deployment example which doesn't even begin to scratch the surface of what is possible when you use IaC "Infrastructure as Code".  But use this simple example as a spring board to grow your knowledge of using these platforms and coded infrastructure.  

After you have been able to deploy the above successfully, try adding a pool, then pool members (the pool members can be basic apache web servers in AWS).  Don't do these changes manually from within the gui or via tmsh.  Do them within the f5Setup.yaml  play book as another task.  Or create a brand new playbook call addPool.yaml, its up to you!  Apply  the changes by re running the command ansible-playbook addPool.yaml.  

Try then adding a virtual server to connect to that pool.  In order to do this, you first need to update your terraform plan to add a secondary ip to your external interface.   Focus on the following  code block

```resource "aws_network_interface" "bigip_external_interface" {
  subnet_id       = "${var.external_subnet_id}"
  private_ips     = ["${var.external_ip}"]
  security_groups = ["${aws_security_group.f5_mgmt_https.id}"]
  attachment {
    instance     = "${aws_instance.bigip_standalone.id}"
    device_index = 1
  }
}```

You'll want to add the  ip in the  private_ips array.  This can be  done statically in the main.tf file or you can add another variable to  variables.tf  and reference  it.  (I suggest variables.tf.  IaC is all about modularity and not tightly coupling configurations.  Variables are super powerful to change alot of things infrastructurely, but only having to change a value in one place )

You may need to also add another EIP depending on your environment

e.g.

```resource "aws_eip" "vs1_eip" {
  vpc      = true
  network_interface         = "${aws_network_interface.bigip_external_interface.id}"
  associate_with_private_ip = "${var.vs_1}" <-- this variable would also be in your private_ips array in the bigip_external_interface resource mentioned above

}```

Save and re apply your terraform plan "terraform apply --auto-approve"

This will update your AWS configuration for your big-ip ec2 instance

After this completes, you will need to update your Big-IP configuration to add the virtual server which will use the newly added private ip address.  Keep adding small changes in this manner to familiarize yourself with ansible and terraform and to build an entire F5 environment servicing up apps all captured in code.  These plans and playbooks or portions of can then be repurposed, edited and ultimately used for future deployments to reduce time of setup.
