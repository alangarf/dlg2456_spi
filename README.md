# dlg2456_spi
VHDL design for an XC9536 to provide a SPI interface to an 8bit DLG2456 LED display

The CPLD I chose was an old XC9536 from Xilinx. In my design I ended up with a simple 9 bit shift register that the controlling micro-controller shifts data into. This data is made up of two "command" bits and seven "data" bits. The micro-controller sets a latch that triggers a state machine to look at the command and decide what to do with the given data.

The support command set is very simple. You have a "clear", a "load character into current position", a "load character into current position and advance position", and a "goto position".

## Command Table
| C1 | C0 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | Description                        |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:-----------------------------------|
| 0 | 0 | X | X | X | X | X | X | X | Clear/Reset display                         |
| 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | Load 'A' into current pos.                  |
| 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | Load 'A' into current pos. and advance pos. |
| 1 | 1 | X | X | X | X | X | 0 | 1 | Goto pos. 1                                 | 

So by using these simple command you can pretty much just send straight ASCII at the controller with an additional two bit and you're done! No tricky software required.

As it stands the CPLD has enough addressing outputs to handle four displays (16 characters) without external decoding. But given for every four I/O pins used (two with external inverters) and the additional two internal addressing bits you can easily add four more displays. With the space left in the CPLD I could see making a 48 character display no problem.

The timing report of the CPLD says the design is good for up to 100MHz, I'm currently running it at 8MHz using a simple pierce gate oscillator. The speed of the clock determines how fast the state machine can accept new commands from the shift register. The "Goto" and "Clear" commands take one clock cycle, while the two "load" commands take two. The DLG2416's are also good for around 10MHz update rate so I think my 8MHz clock is a great fit.

I've been testing the design with my Bus Pirate in 2wire mode and using the AUX pin as the latch. It works quite well but unfortunately doesn't support binary output of anything larger than 8 bits so I'm having to manually transition the pins using `-` for high and `_` for low and `/\` to pulse the AUX latch. Fun! But it does work. The Bus Pirate can also only clock data at 400KHz which means the display update is a little slow when doing multiple characters. Coming from a micro-controller with anything above 1MHz clock speed should be unnoticeable in update.
