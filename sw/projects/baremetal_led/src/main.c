//============================================================================
// Name        : main.cpp
// Author      : veeYceeY
// Version     :
// Copyright   : Your copyright notice
// Description : Hello RISC-V World in C++
//============================================================================

//#include <iostream>
//using namespace std;

#include <stdint.h>
#include "uart.h"
 #include "time.h"
// #include "timer.h"
#define APP_START 0x0080000
// void app_start();
void led(volatile int* gpio,int val);
int sw(volatile int* gpio);
volatile int *gpio;
volatile int *uart;
volatile int *timer;
volatile int switch_val;

int *app_start;
int main()
{
  app_start=(int*) APP_START;
  volatile int rx_data;
  gpio =( volatile int*) 0x00010004;
  uart =uart_init(1);
  uart_set_baud(uart,115200,50000000);
  uart_print(uart,"Starting app..\r\n");
  while(switch_val==0){
      switch_val = *gpio;
      switch_val = switch_val & 0x0F;
 }
  if (switch_val==1){
    uart_print(uart,"1\r\n");
  } else if (switch_val==2){
    uart_print(uart,"2\r\n");
  } else if (switch_val==3){
    uart_print(uart,"3\r\n");
  }
  //((void )*app_start)();
  *gpio=0x05;

  wait_ms(10);
  while (1){
    if(uart_data_ready(uart)==1){
      rx_data=uart_rx(uart);
      uart_tx(uart,rx_data);
      if (rx_data=='b') {    
        led(gpio,0x06);
        }else if(rx_data=='r') {
        led(gpio,0x05);
        }else if(rx_data=='g') {
        led(gpio,0x03);
        }
    }else {
     led(gpio,sw(gpio));
    }
    wait_ms(2);
  }


}
void led(volatile int* gpio,int val){
  *gpio=val;
}
int sw(volatile int* gpio){
  return (*gpio);
}

void exception_handler(uint32_t cause, void * epc, void * saved_sp)
{
  //volatile int* gpio;
  //dd=54;
	//gpio =(int*) 0x00100004;
  if (*gpio==0x00){
    *gpio=0xFF;
  }else{
    *gpio=0x00;
  }
}
