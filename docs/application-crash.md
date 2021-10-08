<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="30%"/><h1>Alveo Debug Guide</h1>
   </td>
 </tr>
</table>

# Application Crash

This page will help you determine if a Vitis™/XRT application crash is caused by card hardware. It is part of the larger Alveo™ debug guide. If you are just starting to debug please consult the [main page](../README.md) to determine if this is the best page for your purposes.

### This Page Covers

Techniques to help you determine if an application crash is caused by hardware or software. Hardware crashes can be caused by an issue in the system hardware, operating the card out of spec, or a bug in the application. This page covers the common cases to determine either that the host and card hardware are operating as expected. Common hardware causes for an application crash are:

* Insufficient power delivered to card - leading to card brown out or SC initiated shutdown
* Insufficient cooling - leading to a card overheat or SC initiated shutdown
* Kernel using more power than the card can provide

Common software causes include user application bugs, invalid memory addresses, and XRT bugs not covered in this guide. These are covered in more detail in the [Application debugging chapter of UG 1416](https://www.xilinx.com/cgi-bin/docs/rdoc?t=vitis+doc;v=latest;d=debuggingapplicationskernels.html).

### You Will Need

To narrow this down, you can look at hardware causes for a crash by:

* Running a known good [Power delivery test](power-delivery.md) to confirm hardware can pass a stress test.
*  Ensure the card is running within limits by running your application + kernel while [monitoring power and temperature](common-steps.md#monitor-card-power-and-temperature).

 If the card passes the stress test, and is operating in power and thermal limits, you are likely to be chasing a software issue covered in more detail in the [Application debugging chapter of UG 1416](https://www.xilinx.com/cgi-bin/docs/rdoc?t=vitis+doc;v=latest;d=debuggingapplicationskernels.html).

## Common Cases
- - -
### [Power delivery test](power-delivery.md) fails.

This means the system is not providing the expected power or cooling. You will see messaging during the diagnostic testing.

Next steps:

*  Follow the troubleshooting steps on the [Power delivery](power-delivery.md) page.


- - -
###  [Power delivery test](power-delivery.md) passes

If both `xbutil validate` and the xbtest stress test pass. The system should have enough power deliver and cooling to run the card within specs.

Meaning:
* The hardware passes the first round of testing with a known test applicaiton.
* It is possible the your application is exceeding card limits

Next steps:

* [Ensure application is running in the power envelope](#ensure-application-is-running-in-the-power-envelope)

- - -
### Ensure application is running in the power envelope

During operation the [SC](terminology.md#sc) is monitoring power and thermal conditions. If the card conditions start to encroach on the limits, the SC can:

* Shut down the kernel - if the card starts to exceed limits
* Reset the card - if the card hits a fatal limit

Checking for this will require you to monitor the card while running your application with a work load that will stress the card harware.
- Use `xbutil query` to [monitor the power rails and temperature](common-steps.md#monitor-card-power-and-temperature) making sure the card is in limits
- Inspect [system logs](common-steps.md#use-system-logs-to-see-if-the-card-exceeded-power-or-thermal-limits) for over temperature and power events.

Keep in mind that temperature events can take time to occur because the card and heat sinks have some thermal mass. Electical loads can ramp up quickly and can happen on application start up.

If the power testing is good this crash is a software application issue, go to the [Application debugging chapter of UG 1416](https://www.xilinx.com/cgi-bin/docs/rdoc?t=vitis+doc;v=latest;d=debuggingapplicationskernels.html).

- - -
###  Card operating in limits and your application crashes

Once you have determined both:

* The card can run a known stress test
* Your application is operating within power and thermal limits

The hardware is likely good. You are likely chasing a software issue in the host code and/or in the acceleration kernel.

Next steps:

* Go to the [Application debugging chapter of UG 1416](https://www.xilinx.com/cgi-bin/docs/rdoc?t=vitis+doc;v=latest;d=debuggingapplicationskernels.html).

- - -

### Xilinx Support

For additional support resources such as Answers, Documentation, Downloads, and Alerts, see the [Xilinx Support pages](http://www.xilinx.com/support). For additional assistance, post your question on the Xilinx Community Forums – [Alveo Accelerator Card](https://forums.xilinx.com/t5/Alveo-Accelerator-Cards/bd-p/alveo). 

Have a suggestion, or found an issue please send an email to alveo_cards_debugging@xilinx.com .

### License

All software including scripts in this distribution are licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

All images and documentation, including all debug and support documentation, are licensed under the Creative Commons (CC) Attribution 4.0 International License (the "CC-BY-4.0 License"); you may not use this file except in compliance with the CC-BY-4.0 License.

You may obtain a copy of the CC-BY-4.0 License at
[https://creativecommons.org/licenses/by/4.0/]( https://creativecommons.org/licenses/by/4.0/)


Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<p align="center"><sup>XD027 | &copy; Copyright 2021 Xilinx, Inc.</sup></p>
