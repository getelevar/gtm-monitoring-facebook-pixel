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

scenarios: []


___NOTES___

Created on 18/02/2020, 18:41:48


