FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to bash
SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libfftw3-dev \
    libgsl-dev \
    python3 \
    python3-dev \
    python3-venv \
    python3-full \
    wget \
    bzip2 \
    tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment with uv
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install uv and Python packages
RUN curl -LsSf https://astral.sh/uv/install.sh | bash && \
    export PATH="$HOME/.local/bin:$PATH" && \
    uv pip install --no-cache \
    numpy \
    scipy \
    matplotlib \
    jupyter \
    pytest \
    ipython

# Install Tcl 8.6.12 from source
RUN cd /tmp && \
    wget https://prdownloads.sourceforge.net/tcl/tcl8.6.5-src.tar.gz && \
    tar -xzf tcl8.6.5-src.tar.gz && \
    cd tcl8.6.5/unix && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf tcl8.6.5* && \
    # Create necessary directories and symbolic links
    mkdir -p /usr/share/simpson/tcl8.6 /usr/share/tcltk/tcl8.6 && \
    ln -sf /usr/local/lib/tcl8.6/init.tcl /usr/share/simpson/tcl8.6/ && \
    ln -sf /usr/local/lib/tcl8.6/init.tcl /usr/share/tcltk/tcl8.6/

# Set Tcl environment variables
ENV PATH="/usr/local/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}" \
    TCL_LIBRARY="/usr/local/lib/tcl8.6" \
    TCLLIBPATH="/usr/local/lib/tcl8.6"

# Download and install SIMPSON 4.2.1
RUN mkdir -p /opt/simpson && \
    cd /opt && \
    wget https://inano.au.dk/fileadmin/user_upload/Simpson_Setup_Linux_4.2.1.tbz2 && \
    tar -xjf Simpson_Setup_Linux_4.2.1.tbz2 && \
    DIR=$(tar -tjf Simpson_Setup_Linux_4.2.1.tbz2 | head -1 | cut -f1 -d"/") && \
    cd "$DIR" && \
    mkdir -p /usr/local/simpson && \
    cp -r * /usr/local/simpson/ && \
    /usr/local/simpson/install.sh && \
    cd /opt && \
    rm -rf Simpson_Setup_Linux_4.2.1.tbz2 "$DIR"

# Set environment variables for SIMPSON
ENV PATH="${PATH}:/usr/local/simpson/bin" \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/simpson/lib"

# Working directory
WORKDIR /workspace

# Command to run when container starts
CMD ["/bin/bash"]