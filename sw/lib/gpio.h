
#define GPIO_WRITE 0

int* gpio_init(int id){
    if (id=='1'){
        return (int*) 0x00100001;
    }
    return 0;
}

void gpio_write(int* dev,int data){
    dev[GPIO_WRITE]=data;
}