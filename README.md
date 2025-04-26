# Introduction

This application is designed to handle MPEG-DASH video streaming efficiently. It provides tools to process, serve, and test DASH-compliant video content using Windows shell scripts.

## How to Run

1. **Install Required Tools**  
    Ensure you have the following tools installed using Chocolatey:
    ```cmd
    choco install ffmpeg gpac php
    ```

2. **Start the Application**  
    Run the main batch script by passing the full path to your video file as an argument:
    ```cmd
    convert.bat C:\path\to\your\video.mp4
    ```

3. **Access the Application**  
    Follow the instructions displayed in the command prompt to proceed.

---

*Author: Marcos Eduardo*

2. **Generate DASH Content**  
    The script will automatically process the video and generate MPEG-DASH content.

3. **Serve DASH Content**  
    The application will serve the generated DASH content for playback.

4. **Test Playback**  
    Use a DASH-compatible player to test the video streaming.

For more details, refer to the documentation or help section.
