/*
Author                      | Date        | Description
Techila Global Services     | 06/29/2018  | Initial Creation of Class
*/

public without sharing class vNHttpFormBuilder {
  //  The boundary is alligned so it doesn't produce padding characters when base64 encoded.
  private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

  /**
   *  Returns the request's content type for multipart/form-data requests.
   */
  public static string GetContentType() {
    return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
  }

  /**
   *  Pad the value with spaces until the base64 encoding is no longer padded.
   */
  private static string SafelyPad(
    string value,
    string valueCrLf64,
    string lineBreaks
  ) {
    string valueCrLf = '';
    blob valueCrLfBlob = null;

    while (valueCrLf64.endsWith('=')) {
      value += ' ';
      valueCrLf = value + lineBreaks;
      valueCrLfBlob = blob.valueOf(valueCrLf);
      valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
    }

    return valueCrLf64;
  }

  /**
   *  Write a boundary between parameters to the form's body.
   */
  public static string WriteBoundary() {
    string value = '--' + Boundary + '\r\n';
    blob valueBlob = blob.valueOf(value);

    return EncodingUtil.base64Encode(valueBlob);
  }

  /**
   *  Write a key-value pair to the form's body.
   */
  public static string WriteBodyParameter(string key, string value) {
    string contentDisposition =
      'Content-Disposition: form-data; name="' +
      key +
      '"';
    string contentDispositionCrLf = contentDisposition + '\r\n\r\n';
    blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
    string contentDispositionCrLf64 = EncodingUtil.base64Encode(
      contentDispositionCrLfBlob
    );
    string content = SafelyPad(
      contentDisposition,
      contentDispositionCrLf64,
      '\r\n\r\n'
    );
    string valueCrLf = value + '\r\n';
    blob valueCrLfBlob = blob.valueOf(valueCrLf);
    string valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);

    content += SafelyPad(value, valueCrLf64, '\r\n');

    return content;
  }
}
