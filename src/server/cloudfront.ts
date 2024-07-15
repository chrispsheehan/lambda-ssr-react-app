import { Request, Response, NextFunction } from 'express';
import axios from 'axios';

const retrieveFileFromCloudFront = (baseUrl: string) => async (req: Request, res: Response, next: NextFunction) => {
  try {
    const fileKey = req.path.substring(1); // Remove leading '/'
    const url = `${baseUrl}/${fileKey}`;
    console.log(`reading ${url}`);

    const response = await axios.get(url, {
      responseType: 'stream'
    });

    res.setHeader('Content-Type', response.headers['content-type']);
    res.setHeader('Content-Length', response.headers['content-length']);

    if (fileKey.endsWith('favicon.ico')) {
      res.setHeader('Content-Type', 'image/x-icon');
    } else {
      res.setHeader('Content-Type', response.headers['content-type']);
    }

    response.data.pipe(res);
  } catch (error) {
    console.error('Error retrieving file from CloudFront:', error);
    res.status(500).send('Error retrieving file from CloudFront');
  }
};

export default retrieveFileFromCloudFront;
