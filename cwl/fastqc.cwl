{
  "hints": [
    {
      "class": "DockerRequirement",
      "dockerPull": "ACCOUNT/fastqc:VERSION"
    }
  ],
  "baseCommand": [
    "run.sh"
  ],
  "class": "CommandLineTool",
  "inputs": [
    {
      "doc": "Input file.",
      "type": [
        "File"
      ],
      "id": "#input_fastq",
      "inputBinding": {
        "position": 1,
        "separate": true,
        "itemSeparator": null
      }
    },
    {
      "doc": "Specifies the number of files which can be processed simultaneously.  Each thread will be allocated 250MB of memory so you shouldn't run more threads than your available memory will cope with, and not more than 6 threads on a 32 bit machine.",
      "type": [
        "null",
        "int"
      ],
      "id": "#threads",
      "default": 1,
      "inputBinding": {
        "position": 2,
        "separate": true
      }
    },
    {
      "type": [
        "null",
        "string"
      ],
      "id": "#outdir",
      "default": ".",
      "inputBinding": {
        "position": 3,
        "separate": true
      }
    }
  ],
  "arguments": [],
  "requirements": [
    {
      "class": "InlineJavascriptRequirement"
    }
  ],
  "cwlVersion": "v1.0",
  "outputs": [
    {
      "doc": "Zip archive of the report.",
      "id": "#report_zip",
      "type": [
        "null",
        "File"
      ],
      "outputBinding": {
        "glob": "*_fastqc.zip"
      }
    }
  ]
}
