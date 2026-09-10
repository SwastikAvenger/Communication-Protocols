# APB Protocol

## Introduction to APB Protocol
The Advanced Peripheral Bus (APB) is a data transfer protocol from the Advanced Microcontroller Bus Architecture (AMBA) family. This protocol is primarily favoured
for low bandwidth peripheral devices.  The APB interface is not pipelined and is a simple, synchronous protocol. Every transfer takes at least two cycles to 
complete. The APB interface is designed for accessing the programmable control registers of peripheral devices. APB peripherals are typically connected to the main 
memory system using an APB bridge. For example, a bridge from AXI to APB could be used to connect a number of APB peripherals to an AXI memory system.
APB transfers are initiated by an APB bridge. APB bridges can also be referred to as a Requester. A peripheral interface responds to requests. APB peripherals 
can also be referred to as a Completer. This specification will use Requester and Completer. 

## Ports/Signal List
The APB protocol uses a 32-bit Address and 32-bit Data bus. In addition, the protocol also has other signals which indicate the state of the peripheral devices, and the status of the transaction. The entire list of signals can be found in the [official documentation](https://support.arm.com/documentation/ihi0024/e/?lang=en). One can download the documentation as a pdf file. _It is advisable to go through the port list before proceeding to the next section._

## Transfers
The APB protocol has two phases of operation - the Address Phase and the Data Phase. The distinction between the two phases is characterized by the status of the PENABLE signal. If the PENABLE signal is low, the controller is in Address Phase, whereas if the PENABLE is high, the controller is in Data Phase. During the Write Operation, when the Master writes onto the Slave, the data is available in the PWDATA bus in the Address Phase. However, during Read Operation, the data is only available in the PRDATA bus in the Data Phase. 
**Write Transfer** and **Read Transfer** are the two types of transfer that are available with the APB Protocol. Both these transfers can occur eithe with or without the Wait State. The Wait State is the state when the APB Slave is NOT READY to accept or transmit data. It is actually helpful to learn about the transfers with the Wait state, since we can see the effect of the PREADY signal in the transaction. 

### Write Transfer with Wait State
The following figure is the timing diagram of the Write Transfer with the Wait State.
<img width="647" height="281" alt="image" src="https://github.com/user-attachments/assets/26c1ef4f-f0d4-49ab-a282-be96007573dd" />

Here, the phase T1 to T2 is the Address Phase. Notice that the PENABE signal is low, so the present phase is the Address Phase. After T2, the PENABLE signal goes high, which indicates that this phase is the Data Phase. However, it is to be noted that, during the time interval T2 to T4, the PREADY signal is low. This signals the master that the APB Slave is not ready for data transaction. Hence the Master "extends" the Data Phase, until the PREADY signal goes high. This is called the Wait State. Once the PREADY signal goes high (at T4), the data is sampled by the APB Slave. Thus, one can say that, the data is available in the PWDATA line from T1 to T5 interval,but is only sampled by the APB Slave in the T4 to T5 interval. 
The following signals remain unchanged while PREADY remains LOW:
* Address signal, PADDR
* Direction signal, PWRITE
* Select signal, PSELx
* Enable signal, PENABLE
* Write data signal, PWDATA
* Write strobe signal, PSTRB
* Protection type signal, PPROT
* User request attribute, PAUSER
* User write data attribute, PWUSER

### Read Transfer with Wait State
The timing diagram for the Read Transfer with the Wait State is shown below.
<img width="650" height="371" alt="image" src="https://github.com/user-attachments/assets/ad5a4b7c-da40-480a-bc4e-3ca1d662c4a9" />

A similar description to the Write Phase will follow. 
During T1 to T2, the PENABLE signal is low. This indicates that the controller is in Address Phase, i.e. the slave is selected by the master (PSEL is high). One should also make a note that the PWRITE signal is low, indicating that a read operation is being performed. From T2 to T5, the PENABLE is high, which indicates that this is the data phase. During this same phase, the PREADY signal is low from T2 to T4. This informs the master that the slave is not ready for any transaction, hence the master goes into a "wait" state, waiting for the PREADY to go high. When the PREADY goes high at T4, the data from the slave is finally made available in the PRDATA line, and the master receives the data. 

## Error Handling in APB Protocol
The Slave Error is signalled when the APB Slave cannot complete the transaction as expected. There could be many reasons for this such as :
* Accessing an invalid address
* An unsupported operation (attempting to write a read only register)
* Internal Slave faults (timeout, hardware failure)

In APB3 and APB4, the slave error is indicated using the PSLVERR signal. If PSLVERR is high, some error has occurred during the transaction, else the transaction is successful. This signal is driven by the slave and becomes valid only when PREADY is high. The Master checks the PSLVERR signal to verify whether the transaction is successful or not. In this project, we have not used the PSLVERR signal. PSLVERR is only considered valid during the last cycle of an APB transfer, when PSEL, PENABLE, and PREADY are all HIGH. It is recommended, but not required, that PSLVERR is driven LOW when PSEL, PENABLE, or PREADY are 
LOW.
The following figures show the Write Transfer with Slave Error and Read Transfer with Slave Error respectively. 

<img width="561" height="316" alt="image" src="https://github.com/user-attachments/assets/dd6586b4-aaab-4849-a567-4a19ba6337d4" />

<img width="652" height="325" alt="image" src="https://github.com/user-attachments/assets/a18b8e8d-3afd-49c5-ad48-01011ea1c536" />

## Operating States of the Protocol
The APB Protocol operates in three states - the IDLE State, SETUP State and ACCESS State. 
* IDLE State: This is the default state, where the bus is inactive. Here, no slave is selected. Transition to the next phase is determined by whether a transfer is required or not. 
* SETUP State: When a transfer is required, the bus enters into the Setup State. In this state, the PSEL is asserted (the slave is chosen), the address-data are asserted, and read/write operation is decided by asserting the PWRITE signal. This state lasts for one clock cycle and goes to the ACCESS phase unconditionally. 
* ACCESS State: The bus enters the ACCESS state once PENABLE is asserted. During this state, the address, write, and data signals must remain stable.
Exit from the ACCESS Phase is controlled by the PREADY signal, from slave.

The following figure shows the FSM diagram of the APB Protocol.

<img width="552" height="505" alt="image" src="https://github.com/user-attachments/assets/5bc358e9-3277-4561-80c2-986433dcacab" />

## Project Overview
Now coming to the project, the project directory has two files - the design file (master.v) and the testbench file (tb_master.v). The master.v file is the source code, which is designed to be the APB Master. It has all the properties discussed above, follows the FSM shown, and generates the proper control signals. The APB Slave is simulated using the testbench file. The files are self-explanatory, once the reader goes through the documentation provided. It is to be noted that this design is intended for Write Operation only, without the Slave Error signal. The Elaborated Design and the Waveform Simulation are shown below, respectively. 

<img width="1288" height="736" alt="Screenshot 2026-09-08 185032" src="https://github.com/user-attachments/assets/e12363c0-20e6-4871-89a9-d826cf529c0c" />

<img width="1442" height="491" alt="Screenshot 2026-09-08 184830" src="https://github.com/user-attachments/assets/8fd3323b-046f-47da-8de8-05ad66a895fa" />

One can use this project as a reference and design their own project. Future work for this project can include (but is not limited to) the addition of the Slave Error, Protection signals and other matching specifications. Good Ideas should have no borders.

