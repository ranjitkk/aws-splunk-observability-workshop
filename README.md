# aws-splunk-observability-workshop
# Runbook: AWS | Splunk DevDay, July 28

Event registration URL: TBD

## Before the Event

To be done: creating a business case and event ticket ...

## Reviewing Code Assets

### Templates

The team template provisions a terminal environment in EC2 with tools required for attendees to interact with the Kubernetes cluster running in Amazon EKS.

Event Engine provisions the team template as a CloudFormation stack when creating the team account and enabling the event module.

This updated event engine template also provisions EKS clusters and nodegroup. The main shell script that is called as CFT bootstrap script is saved in Shell script folder named as create_eks.sh.
The team template provisions the following resources into a team account:
- Service linked role: used by compute instance to assume permissions
- Instance profile: attach service-linked role to compute instance
- Policy document: declaring permissions (access to core services used in workshop only)
- Compute instance: used by attendees as a "terminal in the cloud"
- Security group: blocking/opening ports for network traffic (deny all)

### Policies

The policy document declares permissions assigned to attendees when performing lab instructions. These are automatically provisioned using Event Engine as the team account is set up.

The policy document attached to the team role grants permission to the following core services:

- Elastic Compute Cloud (EC2)
- CloudFormation
- Elastic Container Service for Kubernetes (EKS)
- EC2 Instance Connect
- Simple Storage Service (S3)

Other permissions not explicitly granted to the team role but required by the service-linked role:

- Systems Manager (SSM)

### Attendee Instructions

Event Engine displays attendee instructions for each module as a README file after attendees log into the team dashboard at https://dashboard.eventengine.run/login.

Attendees follow the instructions to configure and deploy a new Kubernetes cluster which will be used throughout the second part of the workshop (Observability with SignalFX and Splunk Cloud).

## Testing Code Assets

### Testing the Team Template

Launch as CloudFormation stack. Test whether the stack launches w/o errors.

### Testing the Team Role

Create role and attach policy. Test whether all AWS console steps complete w/o permission errors.

### Testing the Module instructions

Log into the EC2 instance launched by the stack and run each command line step.

> **Note:** use `screen -S your-session-name` and `screen -r your-session-name` to resume a terminal session in case your browser-based session hangs up.

## Setting up Event Engine

### Blueprint

The event consists of a single blueprint under the `AWS_Default` program. You can inspect the blueprint by logging into Event Engine and navigating to the [admin screen](https://admin.eventengine.run/backend/blueprints).

> **Note:** this blueprint only contains the AWS assets attendees require to complete the overall SignalFX Observability workshop. In addition to the Event Engine team dashboard, attendees also need access to SignalFX and Splunk Cloud.

Refer to the screenshot below.

![Blueprint admin screen in Event Engine](./_images/section-03-img-01.png)

Navigate to the blueprint configuration page by clicking the arrow icon to the right of the blueprint table entry.

![Blueprint admin screen in Event Engine](./_images/section-03-img-02.png)

Once on the configuration page, edit blueprint permissions to grant launch or admin permissions to other event operators in your team.

![Blueprint admin screen in Event Engine](./_images/section-03-img-03.png)

### Module

The event consists of a single module linked under the event blueprint. This module contains the team templates, `README` files, and IAM policies to run the event.

> **Note:** Make sure the module and blueprint are properly linked. Otherwise, your event will start without deploying any assets defined by its modules.

Refer to the screenshot below.

![Module admin screen in Event Engine](./_images/section-03-img-04.png)

Click on a module by clicking on the arrow to the right of the module name and attributes. This will open up the module configuration page.

Event Engine maintains modules as versions. Scroll to the lower half of the screen to see the currently active versions for this module. Click on a version to navigate to its configuration screen.

![Module version screen in Event Engine](./_images/section-03-img-05.png)

The version config screen allows you to administer the master template, team template, 'README' files containing module instructions, and IAM settings. Paste code assets such as CloudFormation templates and IAM policies into the corresponding text boxes.

![Module config screen in Event Engine](./_images/section-03-img-06.png)

Each module offers the ability to upload additional assets to an S3 bucket using the access key and session token provided in the assets tab.

Use this feature to upload any content or scripts you want attendees to download as they complete the module.

> **Note:** the access key and session token only grant write access to the bucket and prefix. However, attendees have public read access to the bucket. Consider using this bucket as a backup option for attendees to deploy CloudFormation scripts or other assets to complete a module.

## Running an Event

### Test Events

Navigate to event admin page. This will be your landing page for administering and creating events. Click on the `Create Event` button to create a new test event.

> **Note:** read through the security and approval reminders to make sure you operate your event within the boundaries defined by the Event Engine [operator guideline](https://w.amazon.com/bin/view/AWS_EventEngine/Documentation/OperatorGuide).

![Event admin screen in Event Engine](./_images/section-04-img-01.png)

Event Engine will take you through a set of event creation steps. First up, set the program (`AWS_Default`), blueprint (`AWS Dev Day (Observability)`), blueprint version (`$DEFAULT`), and event region (e.g., `us-east-1`).

Click `Next Step` to proceed.

![Event admin screen in Event Engine](./_images/section-04-img-02.png)

After completing basic program and blueprint information, Event Engine will ask you to provide additional event details. Start by naming your event (visible to attendees) and specifying the event location (`Remote` in case you are running a virtual workshop).

![Event admin screen in Event Engine](./_images/section-04-img-03.png)

Scroll further.

Now, define your event type. Event Engine recommends you run one test event before scheduling and creating your production event. This makes sure you get to test your permission settings and attendee instructions in the context of the Event Engine [team console](https://dashboard.eventengine.run/login).

> **Note:** each event you create burns an actual AWS account. The account is not recoverable after event termination. Be frugal and do your testing in [Isengard](https://isengard.amazon.com/home).

Set the event type to `Test Event` and configure your usage scenario (in case of Dev Day, set this to `Customer Facing` as you will be testing your event with together with non-AWS customer staff).

![Event admin screen in Event Engine](./_images/section-04-img-04.png)

Scroll further.

Next, set the exact date and start time of your event using the 24 hour format. Also make sure to set the correct time zone for your event to avoid any scheduling issues.

Set the event duration to match the duration of your dry-run with your ISV customer.

> **Note:** always check your dates, times, and time zone to avoid unpleasant surprises. It is not uncommon to make a mistake at this step just to figure out that you are unable to initialize your event at the desired time because of a date/time mix up.

![Event admin screen in Event Engine](./_images/section-04-img-05.png)

Next, write or paste your event description. In the example highlighted below, we paste the public event description from the event landing page and add a disclaimer that this event is a test event.

![Event admin screen in Event Engine](./_images/section-04-img-06.png)

Click `Next Step` to proceed.

In the final section of the event creation screen, enter the name of your customer (`Splunk` in this case).

![Event admin screen in Event Engine](./_images/section-04-img-07.png)

Scroll further.

Configure the number of teams participating in your event and the size of each team. By default, Event Engine only allows a single team to be created as part of a test event. You can add up to 5 players in a given team (players in the same team share a single AWS account).

> **Note:** creating a test event will draw from your development limit. You can check your remaining accounts for development/test purposes in the upper right corner of the event admin page.

You can optionally configure whether teams can set their own name and whether a name choice must be approved by the event operator before starting the event.

![Event admin screen in Event Engine](./_images/section-04-img-08.png)

This complete the setup and configuration of your test event. Click `Create Event` to create the event. Your event is now ready to be initialized and started.

> **Note:** once you create your event, changes to your blueprint and modules will no longer be considered. Make sure to first complete (and possibly lock) your blueprint and module definitions before creating the event.

### Production Event

With the exception of event type and team size configuration, follow the instructions for creating a test event.

In order for your to mark this as a production event, make sure you configure the following settings using the correct values in the `Event Details` tab:

- Event type: set this to `Production Event`
- Internal: set this to `Customer Facing`

Under team details in the `Events & Customers` tab, make sure to configure the following settings using the correct values:

- Number of teams: set this to the number of participating up to the limit granted to your event on approval (applies to events with attendee size > 40)
- Size of teams: set this to the number of attendees you want to share an account during your workshop (make sure attendees are aware that they are sharing an account)

### Initializing an Event

Before players can join and participate in an event, you need to initialize it. Event initialization creates required resources such as team roles, permissions, and CloudFormation stacks for players to use.

In order to initialize and event, navigate to the event landing page. In the event list, click on the arrow button to the right of your event to get to the admin page for your event. Using the `Action` menu button, select `Initialize`.

Event Engine will now begin initializing your event by creating team accounts and deploying required resources into them.

![Admin screen in Event Engine](./_images/section-05-img-01.png)

After initialization of your event, Event Engine will update the event admin page with the current status of initialization. Make sure both the event and individual event teams are properly initialized before proceeding. A traffic light icon indicates the provisioning status of each team.

In the example below, the event has been initialized and team `Test Team` is in status `Ready`. However, the amber status icon indicates that the team template is still in the process of being provisioned.

![Admin screen in Event Engine](./_images/section-05-img-02.png)

Navigate to the team admin page in order to check the status of team template deployment. After initialization of an event, Event Engine provisions the required resources into a team account. This includes the team template (if you specified one). You can monitor progress of the CloudFormation Stack deployment by monitoring the status icon in the team template box as shown in the screenshot below.

![Admin screen in Event Engine](./_images/section-05-img-03.png)

Know when your event is ready. The event status, team status, and team template status should all change to `Ready` or `Provisioned` before players can proceed to log into their team account. You can check the overall event and team status on the event admin page.

![Admin screen in Event Engine](./_images/section-05-img-04.png)

### Starting an Event

To be done ...

<!--

Start the event

Disseminate has code securely and ask attendees to paste it into the team dashboard

Inspect the team console

Inspect the module `README`

Log into the AWS console

Navigate to the EC2 console

Remote into the pre-provisioned EC2 instance

-->

## Troubleshooting

### Troubleshooting Event Configuration

- Check the event start date, time, and time zone is set correctly
- Check event blueprint and modules are linked and the right version is set

### Troubleshooting Cluster Creation

- Check availability zones and EKS availability

### Troubleshooting Permissions

- Check team role permissions
- Check service-linked role permissions

### Break-Glass Access to Team Accounts

To be done ...

## Event Termination

To be done ...
