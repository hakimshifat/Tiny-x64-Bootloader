x64 bit is is basically 64 bit processor. Which is an updated version of 32 bit processor which can use more physical and virtual RAM.

When a PC turns on, it starts reading codes from BIOS(Basic input/output System).

It starts reading from physical location *0xFFFFFFF0* . Which is generally written on *read only systems* like **ROM**.

# **BIOS then POSTs**
- **POST = Power-On Self Test**
- BIOS checks if hardware is working:
    - RAM
    - CPU
    - Keyboard
    - Storage devices
Basically: _“Is the computer healthy enough to start?”_

Then **BIOS** checks for *acceptable boot media*.  The *BIOS* accepts some codes as bootable media if the disks first *512*b is readable and ends in exact bytes 0x55AA. IG it is to say BIOS that it is the end of the boot media.

If BIOS finds some code like it, then BIOS loads the 512 byte to memory address *0x007C00* and transfers program control to this address with a jump instruction to the processor.

Above scenario happens when only 1 drive(storage) is detected. If multiple detected, it starts by priority. ig thats why when i boot linux with pendrive(USB), it automatically loads memory without setting priority. But i think that priority can be overwritten. Cause i have seen some pc what does not do it automatically.


Ok. But real systems ain't 512 byte. What happens it, that 512 byte bootloader loads a bigger bootloader and gives control to that program. One of those bigger bootloader is **GRUB** (its all making sense) It is called *chainloading*.
![](../assets/Pasted%20image%2020260404212648.png)

That bootloader finds the *kernal* and loads it. So basically.
```sh
BIOS
  ↓
[512B Boot Sector]  ← Stage 1
  ↓
[Full Bootloader]   ← Stage 2 (GRUB etc.)
  ↓
[OS Kernel]         ← Stage 3
  ↓
Operating System starts
```

I became curious and ask chatGPT some questions.
# ⚙️ Why BIOS doesn’t load more?

Because BIOS is intentionally **very simple**:
- It does NOT understand filesystems (no FAT/NTFS/ext4 parsing)
- It does NOT know where your OS file is
- It only knows:
    - “Read sector 0”
    - “Check for 0xAA55”
    - “Run it:

# 🚫 So why not make BIOS smarter?

Modern systems actually did — that’s called **UEFI**
But classic BIOS was designed:
- In the 1980s
- For simplicity and compatibility
- When 512 bytes was “enough to bootstrap”

# 🚀 Modern solution: UEFI

UEFI replaces BIOS and removes this limitation:
- Can read filesystems directly
- Loads `.efi` files (no 512-byte restriction)
- Bootloaders can be large programs


There are two modes.

| Feature       | Real Mode (bootloader) | Protected Mode (modern OS) |
| ------------- | ---------------------- | -------------------------- |
| CPU bits      | 16-bit                 | 32/64-bit                  |
| Memory access | Limited, simple        | Advanced (virtual memory)  |
| Safety        | None                   | Memory protection          |
| Multitasking  | No                     | Yes                        |
| OS features   | ❌ None                 | ✅ Full features            |

### Real Mode gives:

✅ Direct hardware + BIOS access  
❌ No modern OS features

### Protected Mode gives:

✅ Modern OS features  
❌ No BIOS interrupts (they stop)


so basically everycomputer that has MBR or GRUB, lives in 19th century for some moments when they boots up.
![](../assets/Pasted%20image%2020260404213606.png)

- Start in **real mode**
- Use BIOS to:
    - Print messages
    - Load kernel from disk
- Then switch to **protected mode**
- Start the real OS
