# 1.Download and install JAM1
1. Goto or make a directory where you would like to put JAM1:
   ```
   cd ~
   mkdir Event_Generator
   cd Event_Generator
   ```
   
2. Download the source file of JAM1 from "https://github.com/ynara305/jam1", or directly type:
   ```
   git clone https://github.com/ynara305/jam1.git
   ```

3. Download the files "main5.f" and "jam.cfg" in my respositories, and move them into:
   ```
   ~/Event_Generator/jam1/main/
   ```

   Now please open main5.f:
   ```
   vim main5.f
   ```

   and have a look at line 23 and line 24
   ```
   23      storage_directory ='/Users/feng/Documents/physics_project' // 
   24      *'/test_storage/jam_sqrt_sNN_7_7_job_'
   ```

   This is the directory where output file "jam_sqrt_sNN_7_7_job_(job_number).dat" will be stored.

   Please modify this, and also remember to modify the sqrt(s_NN) in the file name (say jam_sqrt_sNN_10_5_job_ if you are going to generate events at sqrt(s_NN) = 10.5 GeV ).

4. Generate the "configure" file, first go to:
   ```
   cd ~/Event_Generator/jam1
   ```

   then type:
   ```
   autoreconf -i
   ```
 
  If you don't have autoreconf, please try to download autoreconf:
   
  MacOs:
  
   ```
      brew install autoconf automake libtool
   ```
    
  Linux (I don't test with this):
  
   ```
      sudo apt update && sudo apt install autoconf automake libtool
   ```
    
5. Type
    ```
      ./configure
      make
    ```
    You shall find "jamexe" in "~/Event_Generator/jam1/main". “jamexe” is the executable program.
* Note: whenever you modify main5.f (especially when you modify the diectory of output file), please remember to type "make" before you run jamexe
# 2 Run JAM1 (for test)
Before running JAM1, please go to "~/Event_Generator/jam1/main" check that: 

  (1)the output file directory and filename in main5.f (line 23 and 24), make sure they are correct. If not, modify this and type "make". 

  (2)open "jam.cfg", check
  
    "event" (number of events, for test, set it to be 1, otherwise set it to be 1000)
    
    "win" (the sqrt_sNN, this should match the output filename in main5.f)

    "frame" (This is collider mode for sqrt(sNN) = 7.7 and 11.5 GeV)

Then, it is ready to run JAM1 by typing: 

    ./jamexe [command_argument1] [command_argument2]

Here, "command_argument1" is the random number seed, and "command_argument2" is the job number. For example,

    ./jamexe 195809 1 

so that JAM1 will run with random number seed 195809 and generate output file "YOUR OUTPUT DIRECTORY/jam_sqrt_sNN_7_7_job_1.dat"

# 3 Run JAM1 (for cluster)
  I don't test with this part. In the job submission file, I suggest include the following:

      cd ~/Event_Generator/jam1/main
      random_num=$(od -An -N3 -i /dev/urandom | tr -d ' ') 
      ./jamexe $((random_num+job_number)) $job_number
  Here, job_number should run from 1 to 1000 if 1000 jobs are submitted. 

# 4 JAM1 Parameter setup 
The key parameters in the main5.f are: 
  ```
    mstc(6) = 101 
    mstc(108) = 5 
    mstc(106) =204
  ```
These three parameters mean that JAM1 shall run with mean field mode. 

Other parameters in the main5.f are: 
  ```
    mstc(1) 
  ```
This is the random number seed and set by command argument. Each job should have unique random seed. 

Parameters in the jam.cfg:
  ```
    event =1000 # the number of events to be generated
    proj = 197Au # projectile particle is gold
    targ = 197 Au # target particle is gold
    win = 11.5gev # the sqrt(s_NN) if "frame = collider" (see below)
    bmin = 0.0 # minimum of impact parameter
    bmax = -14.5 # maximum of target parameter
    frame = collider # "collider" is for collider mode, while frame = lab for fixed target mode
    dt = 0.2 # fm/c the magnitude of each time step  of simulation
    timestep = 200 # total number of timestep
