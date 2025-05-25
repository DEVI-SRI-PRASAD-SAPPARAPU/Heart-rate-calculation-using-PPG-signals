# Heart-rate-calculation-using-PPG-signals

Health monitoring systems have become an essential part of modern healthcare. With the increasing prevalence of chronic illnesses and the rising demand for wearable devices, continuous monitoring of physiological parameters like heart rate has gained significant importance. Photoplethysmography (PPG) is a simple, non-invasive optical technique widely used in wearable devices to monitor heart rate, oxygen saturation, and other vital signs.

In this project, we propose a comprehensive heart rate detection system that processes PPG signals using VERILOG and MATLAB. The system performs multiple stages of signal processing, including noise removal, signal quality assessment, and peak detection, to ensure accurate calculation of beats per minute (BPM). By introducing the concept of Signal Quality Index (SQI), the system can identify and exclude noisy or unreliable signals, further improving the robustness of the heart rate calculations. 

While conventional health monitoring systems often use pre-defined thresholds or periodic monitoring approaches, they fail to adapt to the dynamic nature of real-world signals. Our system offers an efficient solution by automatically processing signals, analyzing their quality, and calculating BPM in real time. The integration of MATLAB for signal processing ensures flexibility for algorithm development and validation.

This project also lays the groundwork for future hardware implementation of the PPG block on FPGA platforms using logic synthesis techniques. Such an implementation will enable the integration of the PPG block into wearable devices, providing a reliable and energy-efficient solution for continuous health monitoring. 

