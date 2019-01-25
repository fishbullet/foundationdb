package main

import (
	"fmt"
	"github.com/apple/foundationdb/bindings/go/src/fdb"
	"log"
	"time"
)

func main() {
	fdb.MustAPIVersion(600)
	db := fdb.MustOpenDefault()

	steps := [1000000]int{}
	t1 := time.Now()
	for i := range steps {
		_, e := db.Transact(func(tr fdb.Transaction) (interface{}, error) {
			tr.Set(fdb.Key(fmt.Sprintf("%d", i)), []byte("value"))
			return tr.Get(fdb.Key(fmt.Sprintf("%d", i))).MustGet(), nil
		})
		if e != nil {
			log.Printf("Unable to perform FDB transaction (%v)", e)
		}

		log.Printf("%d put and get", i)
	}
	t2 := time.Now()
	diff := t2.Sub(t1)
	log.Printf("%+v", diff.Seconds())
}
