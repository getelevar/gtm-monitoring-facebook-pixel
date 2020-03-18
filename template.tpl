___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Facebook Pixel / Elevar GTM Monitoring",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "tagName",
    "displayName": "Tag Name",
    "simpleValueType": true,
    "help": "This needs to be equal to the tag name. This is needed for monitoring to work correctly."
  },
  {
    "type": "TEXT",
    "name": "type",
    "displayName": "Type",
    "simpleValueType": true,
    "defaultValue": "track",
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "event",
    "displayName": "Event",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "PARAM_TABLE",
    "name": "content",
    "displayName": "",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "key",
          "displayName": "Key",
          "simpleValueType": true
        },
        "isUnique": true
      },
      {
        "param": {
          "type": "TEXT",
          "name": "value",
          "displayName": "Value",
          "simpleValueType": true
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "variableName",
          "displayName": "Variable Name",
          "simpleValueType": true,
          "enablingConditions": []
        },
        "isUnique": false
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const createQueue = require('createQueue');
const callInWindow = require('callInWindow');

const TAG_INFO = 'elevar_gtm_tag_info';
const addTagInformation = createQueue(TAG_INFO);

if (data.content) {
	const contentObj = {};

    data.content.forEach((item) => {
        contentObj[item.key] = item.value;
    });
  
  	const variablesUsed = data.content
    	.filter(item => item.variableName)
    	.map(item => item.variableName);
  
  	addTagInformation({
		tagName: data.tagName,
      	eventId: data.gtmEventId,
        variables: variablesUsed,
    });
  
    callInWindow('fbq', data.type, data.event, contentObj);
    data.gtmOnSuccess();
} else if (data.event) {
	callInWindow('fbq', data.type, data.event);
	data.gtmOnSuccess();
} else {
	data.gtmOnFailure();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "elevar_gtm_tag_info"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: With Variable Name
  code: |-
    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(calledInWindow).hasLength(1);
    assertThat(calledInWindow[0][0]).isEqualTo('fbq');
    assertThat(calledInWindow[0][1]).isEqualTo('track');
    assertThat(calledInWindow[0][2]).isEqualTo('AddToCart');
    assertThat(calledInWindow[0][3]).isEqualTo({content_ids: "Cool"});
    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0])
      .isEqualTo({
      tagName: 'Facebook - Add to Cart',
      eventId: 13,
      variables: ["dlv - Product View - SKU"]
    });
- name: With No Variable Name
  code: |-
    mockData.content[0] = { key: "test", value:"10", variableName: "" };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('callInWindow').wasCalledWith('fbq', 'track', 'AddToCart', {test: "10"});
    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0])
      .isEqualTo({
      tagName: 'Facebook - Add to Cart',
      eventId: 13,
      variables: []
    });
- name: With Multiple Mixed
  code: |-
    mockData.content.push(
      { key: "currency", value:"USD", variableName: "" },
      { key: "value", value: 30.00, variableName: "dlv - Product Price" }
    );

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('callInWindow').wasCalledWith('fbq', 'track', 'AddToCart', {content_ids: "Cool", currency: 'USD', value: 30.00 });
    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0])
      .isEqualTo({
      tagName: 'Facebook - Add to Cart',
      eventId: 13,
      variables: ["dlv - Product View - SKU", "dlv - Product Price"]
    });
- name: With No Data
  code: |-
    mockData = {
      tagName: "Facebook - Page View",
      type: 'track',
      event: "PageView",
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('callInWindow').wasCalledWith('fbq', 'track', 'PageView');
    assertThat(window[TAG_INFO]).hasLength(0);
setup: "const log = require('logToConsole');\n\n// Custom window object used by mock\
  \ functions\nlet window = {};\nconst TAG_INFO = 'elevar_gtm_tag_info';\n\n// Mock\
  \ data used in template\nlet mockData = {\n  tagName: \"Facebook - Add to Cart\"\
  ,\n  type: \"track\",\n  event: \"AddToCart\",\n  content: [\n    { key: \"content_ids\"\
  , value: \"Cool\", variableName: \"dlv - Product View - SKU\" },\n  ],\n  gtmTagId:\
  \ 2147483645,\n  gtmEventId: 13\n};\n\n/*\nCreates an array in the window with the\
  \ key provided and\nreturns a function that pushes items to that array.\n*/\nmock('createQueue',\
  \ (key) => {\n  const pushToArray = (arr) => (item) => {\n    arr.push(item);\n\
  \  };\n  \n  if (!window[key]) window[key] = [];\n  return pushToArray(window[key]);\n\
  });\n\n/*\ncallInWindow mock function\nsaves data on what function were called and\
  \ with what params.\ncallInWindow('fbq', data.type, data.event, contentObj);\n*/\n\
  let calledInWindow = [];\nmock('callInWindow', function () {\n  const args = arguments;\n\
  \  \n  // Beware: This does not represent exactly what was called.\n  if (args[3])\
  \ {\n\tlog(args[0] + \"('\" + args[1] + \"', '\" + args[2] + \"',\", args[3], \"\
  )\");\n  } else {\n    log(args[0] + \"('\" + args[1] + \"', '\" + args[2] + \"\
  ')\");\n  }\n  calledInWindow.push(args);\n});"


___NOTES___

Created on 18/02/2020, 18:41:48


