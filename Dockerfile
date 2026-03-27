FROM --platform=linux/amd64 continuumio/miniconda3:latest

# Install build dependencies for BTK
# Pin SWIG to 4.0.x — BTK uses %nestedworkaround which was removed in SWIG 4.1+
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/* && \
    conda install -c conda-forge swig=4.0 -y && conda clean -afy

# Create conda environment with pyCGM2 deps (excluding btk, which we build from source)
RUN conda create -n pycgm python=3.10 -y && \
    conda install -n pycgm -c conda-forge -c opensim-org -c defaults \
    "numpy>=1.25,<1.26" \
    openblas \
    opensim \
    scipy \
    matplotlib-base \
    pandas \
    pytest \
    pytest-mpl \
    scikit-learn \
    seaborn \
    beautifulsoup4 \
    yamlordereddictloader \
    openpyxl \
    lxml \
    onnxruntime \
    jinja2 \
    pip \
    -y && \
    conda clean -afy

# Make conda env active by default
ENV PATH=/opt/conda/envs/pycgm/bin:$PATH
ENV CONDA_DEFAULT_ENV=pycgm

# Build BTK from source
RUN git clone https://github.com/d4tt1e/BTKCore.git /src/BTKCore

RUN mkdir /src/BTKCore/build && cd /src/BTKCore/build && \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DBTK_WRAP_PYTHON=ON \
      -DPYTHON_EXECUTABLE=/opt/conda/envs/pycgm/bin/python \
      -DSWIG_EXECUTABLE=/opt/conda/bin/swig \
      -DCMAKE_CXX_FLAGS="-Wno-narrowing -std=c++14" \
      -G "Unix Makefiles" \
      .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Copy BTK Python bindings into the conda env's site-packages
RUN cp /src/BTKCore/build/bin/btk.py /opt/conda/envs/pycgm/lib/python3.10/site-packages/ && \
    cp /src/BTKCore/build/bin/_btk.so /opt/conda/envs/pycgm/lib/python3.10/site-packages/


# Install pyCGM2 from local source.
# Build with: docker build --build-context pycgm2=../pyCGM2 ...
COPY . /src/pyCGM2
RUN cd /src/pyCGM2 && pip install .

# Verify pyCGM2
RUN python -c "import pyCGM2; print('pyCGM2 successfully imported')"

CMD ["bash"]
