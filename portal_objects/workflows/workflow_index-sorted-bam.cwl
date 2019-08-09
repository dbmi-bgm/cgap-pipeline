{
  "accession": "4DNWF3BVZ18F",
  "app_name": "workflow_index-sorted-bam",
  "app_version": "v9",
  "arguments": [
      {
          "argument_format": "bam",
          "argument_type": "Input file",
          "workflow_argument_name": "bam"
      },
      {
          "argument_format": "bai",
          "argument_type": "Output to-be-extra-input file",
          "workflow_argument_name": "bam_index"
      }
  ],
  "award": "1U01CA200059-01",
  "category": ["processing"],
  "cwl_child_filenames": [],
  "cwl_directory_url_v1": "https://raw.githubusercontent.com/dbmi-bgm/cgap-pipeline/master/cwl",
  "cwl_main_filename": "index-sorted-bam.cwl",
  "cwl_pointer": "",
  "description": "Index sorted bam input file.",
  "docker_image_name": "cgap/cgap",
  "docker_registry_url": "https://hub.docker.com/",
  "lab": "4dn-dcic-lab",
  "name": "workflow_index-sorted-bam_v9",
  "aliases": ["4dn-dcic-lab:workflow_index-sorted-bam_v9"],
  "steps": [
      {
          "inputs": [
              {
                  "meta": {
                      "cardinality": "single",
                      "file_format": "bam",
                      "global": true,
                      "type": "data file"
                  },
                  "name": "bam",
                  "source": [
                      {
                          "name": "bam"
                      }
                  ]
              }
          ],
          "meta": {
              "analysis_step_types": [
                  "Index sorted bam input file"
              ],
              "software_used": [
                 "/softwares/3f2d3b0e-0365-4212-9468-c16ad9531c4d"
              ]
          },
          "name": "index-sorted-bam",
          "outputs": [
              {
                  "meta": {
                      "cardinality": "single",
                      "file_format": "bai",
                      "global": true,
                      "type": "data file"
                  },
                  "name": "bam_index",
                  "target": [
                      {
                          "name": "bam_index"
                      }
                  ]
              }
          ]
      }
  ],
  "title": "Index sorted bam file",
  "uuid": "502e4846-a4ab-4da1-a5a3-d835442004a3"
}
