import { TestBed } from '@angular/core/testing';

import { SimpleIpfsService } from './simple-ipfs.service';

describe('SimpleIpfsService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: SimpleIpfsService = TestBed.get(SimpleIpfsService);
    expect(service).toBeTruthy();
  });
});
